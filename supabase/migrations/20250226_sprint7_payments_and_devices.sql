-- Sprint 7: Payments and Payouts tables + user_devices for FCM

-- Payments table (tracks all payment transactions)
CREATE TABLE IF NOT EXISTS payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'QAR',
  method TEXT NOT NULL CHECK (method IN ('sadad', 'cash')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'held_in_escrow', 'released', 'refunded', 'failed')),
  transaction_id TEXT,
  provider_response JSONB,
  released_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_user ON payments(user_id);

-- Payouts table (tracks money distributed to providers)
CREATE TABLE IF NOT EXISTS payouts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL,
  recipient_type TEXT NOT NULL CHECK (recipient_type IN ('shop', 'driver', 'workshop')),
  amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'not_applicable')),
  bank_reference TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payouts_payment ON payouts(payment_id);
CREATE INDEX idx_payouts_recipient ON payouts(recipient_id);

-- User devices table (FCM tokens)
CREATE TABLE IF NOT EXISTS user_devices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  platform TEXT DEFAULT 'android' CHECK (platform IN ('android', 'ios', 'web')),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, fcm_token)
);

CREATE INDEX idx_user_devices_user ON user_devices(user_id);

-- RLS for payments
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own payments"
  ON payments FOR SELECT
  USING (user_id = auth.uid());

-- RLS for payouts
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Recipients can view their payouts"
  ON payouts FOR SELECT
  USING (recipient_id = auth.uid());

-- RLS for user_devices
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own devices"
  ON user_devices FOR ALL
  USING (user_id = auth.uid());

-- Add payment_id to orders if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'payment_id'
  ) THEN
    ALTER TABLE orders ADD COLUMN payment_id UUID REFERENCES payments(id);
  END IF;
END $$;
