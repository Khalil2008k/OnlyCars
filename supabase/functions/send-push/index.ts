// Supabase Edge Function: send-push
// Sends FCM push notifications to user devices

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface PushRequest {
    user_id: string;
    title: string;
    body: string;
    data?: Record<string, string>;
}

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const fcmServerKey = Deno.env.get("FCM_SERVER_KEY") || "";

        const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

        const payload: PushRequest = await req.json();

        // Get user's FCM tokens
        const { data: devices } = await supabaseAdmin
            .from("user_devices")
            .select("fcm_token, platform")
            .eq("user_id", payload.user_id)
            .eq("is_active", true);

        if (!devices || devices.length === 0) {
            return new Response(JSON.stringify({ sent: 0, reason: "No devices" }), {
                status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        let sentCount = 0;

        for (const device of devices) {
            try {
                // FCM HTTP v1 API
                const fcmResponse = await fetch(
                    "https://fcm.googleapis.com/fcm/send",
                    {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            "Authorization": `key=${fcmServerKey}`,
                        },
                        body: JSON.stringify({
                            to: device.fcm_token,
                            notification: {
                                title: payload.title,
                                body: payload.body,
                                sound: "default",
                                badge: 1,
                            },
                            data: payload.data || {},
                            priority: "high",
                            content_available: true,
                        }),
                    }
                );

                if (fcmResponse.ok) {
                    sentCount++;
                } else {
                    // Token might be expired — mark inactive
                    const result = await fcmResponse.json();
                    if (result.failure > 0) {
                        await supabaseAdmin
                            .from("user_devices")
                            .update({ is_active: false })
                            .eq("fcm_token", device.fcm_token);
                    }
                }
            } catch (e) {
                console.error(`FCM send error for token ${device.fcm_token}:`, e);
            }
        }

        // Also save to notifications table for in-app display
        await supabaseAdmin.from("notifications").insert({
            user_id: payload.user_id,
            type: payload.data?.type || "general",
            title: payload.title,
            body: payload.body,
            data: payload.data || {},
        });

        return new Response(JSON.stringify({
            success: true,
            sent: sentCount,
            total_devices: devices.length,
        }), {
            status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });

    } catch (err: any) {
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});
