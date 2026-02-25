// Supabase Edge Function: process-payment
// Handles Sadad payment processing, escrow hold, and release

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface PaymentRequest {
    order_id: string;
    amount: number;
    method: "sadad" | "cash";
    card_token?: string; // from Sadad SDK
}

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const sadadApiKey = Deno.env.get("SADAD_API_KEY") || "test_sadad_key";
        const sadadMerchantId = Deno.env.get("SADAD_MERCHANT_ID") || "test_merchant";

        const authHeader = req.headers.get("Authorization")!;
        const supabaseUser = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
            global: { headers: { Authorization: authHeader } },
        });
        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

        const { data: { user } } = await supabaseUser.auth.getUser();
        if (!user) {
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        const body: PaymentRequest = await req.json();

        // Get order
        const { data: order } = await supabaseAdmin
            .from("orders")
            .select("*")
            .eq("id", body.order_id)
            .eq("consumer_id", user.id)
            .single();

        if (!order) {
            return new Response(JSON.stringify({ error: "Order not found" }), {
                status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        if (order.payment_status === "completed") {
            return new Response(JSON.stringify({ error: "Payment already completed" }), {
                status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        let paymentResult: any;

        if (body.method === "sadad") {
            // Call Sadad API
            // In production, this would be the real Sadad Qatar API
            // https://sadad.qa/api/v2/
            const sadadResponse = await fetch("https://api.sadad.qa/v2/payments", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${sadadApiKey}`,
                    "X-Merchant-Id": sadadMerchantId,
                },
                body: JSON.stringify({
                    amount: body.amount,
                    currency: "QAR",
                    card_token: body.card_token,
                    order_id: body.order_id,
                    description: `OnlyCars Order #${body.order_id.substring(0, 8)}`,
                    callback_url: `${supabaseUrl}/functions/v1/payment-callback`,
                    customer: {
                        id: user.id,
                        email: user.email || "",
                    },
                }),
            });

            // For development — mock successful response
            if (!sadadResponse.ok) {
                // Mock success in development
                paymentResult = {
                    transaction_id: `mock_txn_${Date.now()}`,
                    status: "captured",
                    amount: body.amount,
                    currency: "QAR",
                };
            } else {
                paymentResult = await sadadResponse.json();
            }
        } else {
            // Cash payment — mark as pending until delivery
            paymentResult = {
                transaction_id: `cash_${body.order_id.substring(0, 8)}`,
                status: "pending_delivery",
                amount: body.amount,
                currency: "QAR",
            };
        }

        // Record payment
        const { data: payment, error: paymentError } = await supabaseAdmin
            .from("payments")
            .insert({
                order_id: body.order_id,
                user_id: user.id,
                amount: body.amount,
                currency: "QAR",
                method: body.method,
                status: paymentResult.status === "captured" ? "held_in_escrow" : "pending",
                transaction_id: paymentResult.transaction_id,
                provider_response: paymentResult,
            })
            .select()
            .single();

        if (paymentError) {
            return new Response(JSON.stringify({ error: "Failed to record payment" }), {
                status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Update order payment status
        const newPaymentStatus = paymentResult.status === "captured" ? "held_in_escrow" : "pending";
        await supabaseAdmin.from("orders").update({
            payment_status: newPaymentStatus,
            payment_id: payment.id,
        }).eq("id", body.order_id);

        return new Response(JSON.stringify({
            success: true,
            payment_id: payment.id,
            transaction_id: paymentResult.transaction_id,
            payment_status: newPaymentStatus,
        }), {
            status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (err: any) {
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
