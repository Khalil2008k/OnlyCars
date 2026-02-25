// Supabase Edge Function: update-order-status
// Handles order status transitions and dispatches notifications to all parties

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Valid status transitions
const validTransitions: Record<string, string[]> = {
    pending: ["confirmed", "cancelled"],
    confirmed: ["preparing"],
    preparing: ["ready"],
    ready: ["picked_up"],
    picked_up: ["delivered"],
    delivered: ["completed"],
};

// Arabic status labels
const statusLabels: Record<string, string> = {
    confirmed: "مؤكد",
    preparing: "قيد التجهيز",
    ready: "جاهز للاستلام",
    picked_up: "تم الاستلام",
    delivered: "تم التوصيل",
    completed: "مكتمل",
    cancelled: "ملغي",
};

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const authHeader = req.headers.get("Authorization")!;

        const supabaseUser = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
            global: { headers: { Authorization: authHeader } },
        });
        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

        const { data: { user }, error: authError } = await supabaseUser.auth.getUser();
        if (authError || !user) {
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const { order_id, new_status } = await req.json();

        // Get current order
        const { data: order, error: orderError } = await supabaseAdmin
            .from("orders")
            .select("*")
            .eq("id", order_id)
            .single();

        if (orderError || !order) {
            return new Response(JSON.stringify({ error: "Order not found" }), {
                status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Validate transition
        const allowed = validTransitions[order.status];
        if (!allowed || !allowed.includes(new_status)) {
            return new Response(JSON.stringify({
                error: `Cannot transition from ${order.status} to ${new_status}`,
            }), {
                status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Update order status
        const updates: any = { status: new_status, updated_at: new Date().toISOString() };

        // If delivered → mark payment as completed for cash
        if (new_status === "delivered" && order.payment_method === "cash") {
            updates.payment_status = "completed";
        }

        // If completed → set completed_at
        if (new_status === "completed") {
            updates.completed_at = new Date().toISOString();
        }

        await supabaseAdmin.from("orders").update(updates).eq("id", order_id);

        // Add to order_status_history
        await supabaseAdmin.from("order_status_history").insert({
            order_id,
            status: new_status,
            changed_by: user.id,
        });

        // Notify consumer
        await supabaseAdmin.from("notifications").insert({
            user_id: order.consumer_id,
            type: "order_update",
            title: `تحديث الطلب #${order_id.substring(0, 6)}`,
            body: `الحالة: ${statusLabels[new_status] || new_status}`,
            data: { order_id, status: new_status },
        });

        return new Response(JSON.stringify({
            success: true,
            order_id,
            status: new_status,
        }), {
            status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
