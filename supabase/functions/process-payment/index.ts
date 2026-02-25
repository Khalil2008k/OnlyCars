// Supabase Edge Function: process-payment
// Handles Sadad payment processing via invoice-based flow
//
// Sadad Account: BLACK ENERGY TECH
// Merchant ID: 2334863
// API: REST / JSON — invoice insert → payment URL → webhook callback
//
// Environment Variables Required:
//   SADAD_SECRET_KEY  — from Sadad Dashboard → Payment Gateway → Live Key
//   SADAD_MERCHANT_ID — 2334863

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Sadad API configuration
const SADAD_BASE_URL = "https://api.sadadqa.com";
const SADAD_INVOICE_ENDPOINT = `${SADAD_BASE_URL}/api/v1/invoices`;

interface PaymentRequest {
    order_id: string;
    amount: number;
    method: "sadad" | "cash";
    customer_name?: string;
    customer_phone?: string;
    customer_email?: string;
}

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const sadadSecretKey = Deno.env.get("SADAD_SECRET_KEY") || "";
        const sadadMerchantId = Deno.env.get("SADAD_MERCHANT_ID") || "2334863";

        const authHeader = req.headers.get("Authorization")!;
        const supabaseUser = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
            global: { headers: { Authorization: authHeader } },
        });
        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

        // Authenticate user
        const { data: { user } } = await supabaseUser.auth.getUser();
        if (!user) {
            return new Response(JSON.stringify({ error: "غير مصرح" }), {
                status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const body: PaymentRequest = await req.json();

        // ── Get order ──────────────────────────────────────────
        const { data: order } = await supabaseAdmin
            .from("orders")
            .select("*, order_items:order_items(*)")
            .eq("id", body.order_id)
            .eq("consumer_id", user.id)
            .single();

        if (!order) {
            return new Response(JSON.stringify({ error: "الطلب غير موجود" }), {
                status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        if (order.payment_status === "completed" || order.payment_status === "held_in_escrow") {
            return new Response(JSON.stringify({ error: "تم الدفع مسبقاً" }), {
                status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        let paymentResult: any;
        let invoiceUrl: string | null = null;

        // ── Sadad Card Payment ─────────────────────────────────
        if (body.method === "sadad") {

            // Build line items from order
            const lineItems = (order.order_items || []).map((item: any, idx: number) => ({
                name: item.part_name_ar || `قطعة ${idx + 1}`,
                quantity: item.quantity,
                unit_amount: item.unit_price,
            }));

            // Add delivery fee as line item
            if (order.delivery_fee > 0) {
                lineItems.push({
                    name: "رسوم التوصيل",
                    quantity: 1,
                    unit_amount: order.delivery_fee,
                });
            }

            // Create Sadad invoice
            const invoicePayload = {
                merchant_id: sadadMerchantId,
                amount: body.amount,
                currency: "QAR",
                description: `طلب OnlyCars #${body.order_id.substring(0, 8)}`,
                reference_id: body.order_id,
                customer: {
                    name: body.customer_name || user.user_metadata?.name || "عميل",
                    phone: body.customer_phone || user.phone || "",
                    email: body.customer_email || user.email || "",
                },
                items: lineItems,
                callback_url: `${supabaseUrl}/functions/v1/payment-callback`,
                success_url: `https://onlycars.qa/payment/success?order=${body.order_id}`,
                failure_url: `https://onlycars.qa/payment/failed?order=${body.order_id}`,
                metadata: {
                    order_id: body.order_id,
                    user_id: user.id,
                    platform: "onlycars",
                },
            };

            try {
                const sadadResponse = await fetch(SADAD_INVOICE_ENDPOINT, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${sadadSecretKey}`,
                    },
                    body: JSON.stringify(invoicePayload),
                });

                if (sadadResponse.ok) {
                    const sadadResult = await sadadResponse.json();
                    paymentResult = {
                        transaction_id: sadadResult.invoice_id || sadadResult.id || `sadad_${Date.now()}`,
                        status: "pending_payment",
                        amount: body.amount,
                        currency: "QAR",
                        provider_data: sadadResult,
                    };
                    invoiceUrl = sadadResult.invoice_url || sadadResult.payment_url || null;
                } else {
                    // API returned error — log it but create payment in pending state
                    const errorText = await sadadResponse.text();
                    console.error("[Sadad] API error:", sadadResponse.status, errorText);

                    paymentResult = {
                        transaction_id: `sadad_pending_${Date.now()}`,
                        status: "pending_payment",
                        amount: body.amount,
                        currency: "QAR",
                        error: errorText,
                    };
                }
            } catch (fetchError) {
                // Network error — still create payment record
                console.error("[Sadad] Network error:", fetchError);
                paymentResult = {
                    transaction_id: `sadad_err_${Date.now()}`,
                    status: "failed",
                    amount: body.amount,
                    currency: "QAR",
                };
            }

            // ── Cash on Delivery ───────────────────────────────────
        } else {
            paymentResult = {
                transaction_id: `cash_${body.order_id.substring(0, 8)}`,
                status: "pending_delivery",
                amount: body.amount,
                currency: "QAR",
            };
        }

        // ── Record payment ─────────────────────────────────────
        const paymentStatus = paymentResult.status === "pending_payment"
            ? "processing"
            : paymentResult.status === "pending_delivery"
                ? "pending"
                : "failed";

        const { data: payment, error: paymentError } = await supabaseAdmin
            .from("payments")
            .insert({
                order_id: body.order_id,
                user_id: user.id,
                amount: body.amount,
                currency: "QAR",
                method: body.method,
                status: paymentStatus,
                transaction_id: paymentResult.transaction_id,
                provider_response: paymentResult,
            })
            .select()
            .single();

        if (paymentError) {
            console.error("[Payment] Insert error:", paymentError);
            return new Response(JSON.stringify({ error: "فشل في تسجيل الدفع" }), {
                status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Update order
        await supabaseAdmin.from("orders").update({
            payment_status: paymentStatus,
            payment_id: payment.id,
        }).eq("id", body.order_id);

        // ── Return response ────────────────────────────────────
        return new Response(JSON.stringify({
            success: true,
            payment_id: payment.id,
            transaction_id: paymentResult.transaction_id,
            payment_status: paymentStatus,
            // If Sadad, return the invoice URL for user to complete payment
            invoice_url: invoiceUrl,
        }), {
            status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (err: any) {
        console.error("[process-payment] Fatal:", err);
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
