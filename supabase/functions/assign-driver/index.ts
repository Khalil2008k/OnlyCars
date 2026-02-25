// Supabase Edge Function: assign-driver
// Finds nearest available driver and assigns them to a ready order

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

        const authHeader = req.headers.get("Authorization")!;
        const supabaseUser = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
            global: { headers: { Authorization: authHeader } },
        });

        const { data: { user } } = await supabaseUser.auth.getUser();
        if (!user) {
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const { order_id } = await req.json();

        // Get order
        const { data: order } = await supabaseAdmin
            .from("orders")
            .select("*, shop:shops(name_ar, lat, lng)")
            .eq("id", order_id)
            .eq("status", "ready")
            .single();

        if (!order) {
            return new Response(JSON.stringify({ error: "Order not found or not ready" }), {
                status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Find available drivers
        const { data: drivers } = await supabaseAdmin
            .from("drivers")
            .select("id, user_id, current_lat, current_lng")
            .eq("is_available", true)
            .eq("is_verified", true)
            .limit(10);

        if (!drivers || drivers.length === 0) {
            return new Response(JSON.stringify({ error: "No available drivers" }), {
                status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Simple nearest driver (haversine would be better, but for Qatar's size this is fine)
        const shopLat = order.shop?.lat || 25.2854;
        const shopLng = order.shop?.lng || 51.5310;

        let nearestDriver = drivers[0];
        let minDist = Infinity;

        for (const d of drivers) {
            const dist = Math.sqrt(
                Math.pow((d.current_lat || 25.28) - shopLat, 2) +
                Math.pow((d.current_lng || 51.53) - shopLng, 2)
            );
            if (dist < minDist) {
                minDist = dist;
                nearestDriver = d;
            }
        }

        // Create delivery assignment
        const { data: delivery, error: deliveryError } = await supabaseAdmin
            .from("deliveries")
            .insert({
                order_id,
                driver_id: nearestDriver.id,
                status: "assigned",
                pickup_lat: shopLat,
                pickup_lng: shopLng,
            })
            .select()
            .single();

        if (deliveryError) {
            return new Response(JSON.stringify({ error: "Failed to assign driver" }), {
                status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Update order
        await supabaseAdmin.from("orders").update({
            driver_id: nearestDriver.id,
            status: "picked_up",
        }).eq("id", order_id);

        // Notify driver
        await supabaseAdmin.from("notifications").insert({
            user_id: nearestDriver.user_id,
            type: "delivery_assigned",
            title: "توصيلة جديدة",
            body: `طلب جديد للتوصيل من ${order.shop?.name_ar || 'المتجر'} — ${order.delivery_fee} ر.ق`,
            data: { order_id, delivery_id: delivery.id },
        });

        return new Response(JSON.stringify({
            success: true,
            delivery_id: delivery.id,
            driver_id: nearestDriver.id,
        }), {
            status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
