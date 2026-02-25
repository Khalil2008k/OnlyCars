// Supabase Edge Function: release-escrow
// Releases held payment to provider after order completion

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

        // Get order + payment
        const { data: order } = await supabaseAdmin
            .from("orders")
            .select("*, payment:payments(*)")
            .eq("id", order_id)
            .eq("status", "completed")
            .single();

        if (!order) {
            return new Response(JSON.stringify({ error: "Order not found or not completed" }), {
                status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const payment = Array.isArray(order.payment) ? order.payment[0] : order.payment;
        if (!payment || payment.status !== "held_in_escrow") {
            return new Response(JSON.stringify({ error: "No escrowed payment found" }), {
                status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Calculate splits
        const total = payment.amount;
        const platformFee = order.platform_fee || Math.round(total * 0.15 * 100) / 100;
        const shopPayout = order.subtotal - platformFee;
        const driverPayout = order.delivery_fee;

        // Create payout records
        const payouts = [];

        if (order.shop_id) {
            payouts.push({
                payment_id: payment.id,
                recipient_id: order.shop_id,
                recipient_type: "shop",
                amount: shopPayout,
                status: "pending",
            });
        }

        if (order.driver_id) {
            payouts.push({
                payment_id: payment.id,
                recipient_id: order.driver_id,
                recipient_type: "driver",
                amount: driverPayout,
                status: "pending",
            });
        }

        if (order.workshop_id) {
            // Workshop gets labor fee (not from escrow — billed separately)
            payouts.push({
                payment_id: payment.id,
                recipient_id: order.workshop_id,
                recipient_type: "workshop",
                amount: 0, // Labor is billed separately
                status: "not_applicable",
            });
        }

        await supabaseAdmin.from("payouts").insert(payouts);

        // Update payment status
        await supabaseAdmin.from("payments").update({
            status: "released",
            released_at: new Date().toISOString(),
        }).eq("id", payment.id);

        // Update order
        await supabaseAdmin.from("orders").update({
            payment_status: "released",
        }).eq("id", order_id);

        // Notify providers
        for (const payout of payouts) {
            if (payout.status === "pending" && payout.amount > 0) {
                await supabaseAdmin.from("notifications").insert({
                    user_id: payout.recipient_id,
                    type: "payout",
                    title: "أرباح جديدة",
                    body: `تم تحويل ${payout.amount} ر.ق لحسابك من الطلب #${order_id.substring(0, 6)}`,
                    data: { order_id, payout_amount: payout.amount },
                });
            }
        }

        return new Response(JSON.stringify({
            success: true,
            payouts: payouts.map(p => ({
                recipient_type: p.recipient_type,
                amount: p.amount,
                status: p.status,
            })),
            platform_fee: platformFee,
        }), {
            status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (err: any) {
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
