// Supabase Edge Function: place-order
// Handles order creation, stock validation, and notification dispatch

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface OrderItem {
  part_id: string;
  quantity: number;
}

interface PlaceOrderRequest {
  items: OrderItem[];
  workshop_code?: string;
  delivery_address_id?: string;
  payment_method: "cash" | "sadad";
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const authHeader = req.headers.get("Authorization")!;

    // User client (RLS enforced)
    const supabaseUser = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } },
    });

    // Admin client (bypasses RLS)
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Get authenticated user
    const { data: { user }, error: authError } = await supabaseUser.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body: PlaceOrderRequest = await req.json();

    // 1. Validate stock availability
    const partIds = body.items.map((i) => i.part_id);
    const { data: parts, error: partsError } = await supabaseAdmin
      .from("parts")
      .select("id, name_ar, price, stock_qty, shop_id")
      .in_("id", partIds);

    if (partsError || !parts || parts.length !== partIds.length) {
      return new Response(JSON.stringify({ error: "Invalid parts" }), {
        status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Check stock
    for (const item of body.items) {
      const part = parts.find((p: any) => p.id === item.part_id);
      if (!part || part.stock_qty < item.quantity) {
        return new Response(JSON.stringify({
          error: `Insufficient stock for ${part?.name_ar || item.part_id}`,
        }), {
          status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // 2. Calculate totals
    let subtotal = 0;
    const orderItems = body.items.map((item) => {
      const part = parts.find((p: any) => p.id === item.part_id)!;
      const lineTotal = part.price * item.quantity;
      subtotal += lineTotal;
      return { part_id: item.part_id, quantity: item.quantity, unit_price: part.price, line_total: lineTotal };
    });

    const deliveryFee = 25; // QAR flat rate — configurable later
    const platformFee = Math.round(subtotal * 0.15 * 100) / 100; // 15% commission
    const total = subtotal + deliveryFee;

    // 3. Resolve workshop (optional)
    let workshopId = null;
    if (body.workshop_code) {
      const { data: ws } = await supabaseAdmin
        .from("workshops")
        .select("id")
        .eq("workshop_code", body.workshop_code)
        .single();
      workshopId = ws?.id || null;
    }

    // Group items by shop
    const shopId = parts[0].shop_id;

    // 4. Create order
    const { data: order, error: orderError } = await supabaseAdmin
      .from("orders")
      .insert({
        consumer_id: user.id,
        shop_id: shopId,
        workshop_id: workshopId,
        status: "pending",
        subtotal,
        delivery_fee: deliveryFee,
        platform_fee: platformFee,
        total,
        payment_method: body.payment_method,
        payment_status: body.payment_method === "cash" ? "pending" : "processing",
      })
      .select()
      .single();

    if (orderError) {
      return new Response(JSON.stringify({ error: "Failed to create order", detail: orderError.message }), {
        status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 5. Insert order items
    const itemsToInsert = orderItems.map((item) => ({
      ...item,
      order_id: order.id,
    }));

    await supabaseAdmin.from("order_items").insert(itemsToInsert);

    // 6. Decrement stock
    for (const item of body.items) {
      await supabaseAdmin.rpc("decrement_stock", {
        p_part_id: item.part_id,
        p_qty: item.quantity,
      });
    }

    // 7. Create notification for shop
    await supabaseAdmin.from("notifications").insert({
      user_id: shopId, // shop owner
      type: "new_order",
      title: "طلب جديد",
      body: `طلب جديد #${order.id.substring(0, 6)} — ${orderItems.length} قطع — ${total} ر.ق`,
      data: { order_id: order.id },
    });

    return new Response(JSON.stringify({
      success: true,
      order_id: order.id,
      total,
      status: "pending",
    }), {
      status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
