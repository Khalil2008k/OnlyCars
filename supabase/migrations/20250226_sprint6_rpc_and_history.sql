-- Add decrement_stock RPC function (referenced by place-order edge function)
CREATE OR REPLACE FUNCTION decrement_stock(p_part_id UUID, p_qty INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE parts
  SET stock_qty = stock_qty - p_qty,
      updated_at = NOW()
  WHERE id = p_part_id
    AND stock_qty >= p_qty;
    
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Insufficient stock for part %', p_part_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add order_status_history table (referenced by update-order-status edge function)
CREATE TABLE IF NOT EXISTS order_status_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  changed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_order_status_history_order ON order_status_history(order_id);

-- RLS for order_status_history
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their order history"
  ON order_status_history FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders WHERE consumer_id = auth.uid()
    )
  );
