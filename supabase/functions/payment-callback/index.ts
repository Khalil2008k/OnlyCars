// Supabase Edge Function: payment-callback
// Webhook called by Sadad when payment completes or fails
//
// Sadad sends a POST with payment result to this endpoint.
// Configure this URL in Sadad Dashboard → Payment Gateway → Webhook tab:
//   https://wfzwrcqpjrzqpgawiess.supabase.co/functions/v1/payment-callback

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

        const payload = await req.json();
        console.log("[Sadad Callback] Payload:", JSON.stringify(payload));

        // Sadad callback fields (typical structure)
        const orderId = payload.reference_id || payload.metadata?.order_id || payload.order_id;
        const invoiceId = payload.invoice_id || payload.id;
        const status = payload.status; // "paid", "failed", "expired", "cancelled"
        const transactionId = payload.transaction_id || invoiceId;
        const amountPaid = payload.amount || payload.amount_paid;

        if (!orderId) {
            console.error("[Sadad Callback] No order_id in payload");
            return new Response(JSON.stringify({ error: "Missing order reference" }), {
                status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Map Sadad status to our payment status
        let ourStatus: string;
        let orderPaymentStatus: string;

        switch (status?.toLowerCase()) {
            case "paid":
            case "captured":
            case "success":
                ourStatus = "held_in_escrow";
                orderPaymentStatus = "held_in_escrow";
                break;
            case "failed":
            case "declined":
                ourStatus = "failed";
                orderPaymentStatus = "failed";
                break;
            case "expired":
                ourStatus = "failed";
                orderPaymentStatus = "expired";
                break;
            case "cancelled":
            case "canceled":
                ourStatus = "failed";
                orderPaymentStatus = "cancelled";
                break;
            default:
                ourStatus = "processing";
                orderPaymentStatus = "processing";
        }

        // Update payment record
        const { data: payment } = await supabaseAdmin
            .from("payments")
            .update({
                status: ourStatus,
                transaction_id: transactionId,
                provider_response: payload,
                updated_at: new Date().toISOString(),
            })
            .eq("order_id", orderId)
            .select()
            .single();

        // Update order payment status
        await supabaseAdmin.from("orders").update({
            payment_status: orderPaymentStatus,
        }).eq("id", orderId);

        // If payment succeeded, confirm the order
        if (ourStatus === "held_in_escrow") {
            // Update order status to confirmed
            await supabaseAdmin.from("orders").update({
                status: "confirmed",
            }).eq("id", orderId).eq("status", "pending");

            // Log status history
            await supabaseAdmin.from("order_status_history").insert({
                order_id: orderId,
                old_status: "pending",
                new_status: "confirmed",
                changed_by: "system",
                note: "تم تأكيد الطلب بعد الدفع عبر سداد",
            });

            // Notify consumer
            const { data: order } = await supabaseAdmin
                .from("orders")
                .select("consumer_id")
                .eq("id", orderId)
                .single();

            if (order) {
                await supabaseAdmin.from("notifications").insert({
                    user_id: order.consumer_id,
                    type: "payment_success",
                    title: "تم الدفع بنجاح ✅",
                    body: `تم تأكيد دفع ${amountPaid} ر.ق للطلب #${orderId.substring(0, 6)}`,
                    data: { order_id: orderId, amount: amountPaid },
                });
            }

            // Notify shop to prepare
            const { data: orderFull } = await supabaseAdmin
                .from("orders")
                .select("shop_id")
                .eq("id", orderId)
                .single();

            if (orderFull?.shop_id) {
                await supabaseAdmin.from("notifications").insert({
                    user_id: orderFull.shop_id,
                    type: "new_order",
                    title: "طلب جديد 🛒",
                    body: `طلب جديد بقيمة ${amountPaid} ر.ق — يرجى تجهيزه`,
                    data: { order_id: orderId },
                });
            }
        }

        // If payment failed, notify consumer
        if (ourStatus === "failed" && payment) {
            const { data: order } = await supabaseAdmin
                .from("orders")
                .select("consumer_id")
                .eq("id", orderId)
                .single();

            if (order) {
                await supabaseAdmin.from("notifications").insert({
                    user_id: order.consumer_id,
                    type: "payment_failed",
                    title: "فشل الدفع ❌",
                    body: `لم يتم إكمال الدفع للطلب #${orderId.substring(0, 6)}. يرجى المحاولة مرة أخرى.`,
                    data: { order_id: orderId },
                });
            }
        }

        return new Response(JSON.stringify({
            success: true,
            order_id: orderId,
            payment_status: ourStatus,
        }), {
            status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (err: any) {
        console.error("[payment-callback] Fatal:", err);
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
