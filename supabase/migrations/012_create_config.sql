-- ============================================
-- OnlyCars Migration 012: Config + Delivery Zones
-- ============================================

CREATE TABLE IF NOT EXISTS public.delivery_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_ar TEXT NOT NULL,
    name_en TEXT,
    base_fee NUMERIC(10,2) NOT NULL DEFAULT 15.00,
    per_km_fee NUMERIC(10,2) NOT NULL DEFAULT 2.00,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.platform_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed default config
INSERT INTO public.platform_config (key, value, description) VALUES
    ('commission_rate', '"0.05"', 'Platform commission percentage (5%)'),
    ('min_app_version', '"1.0.0"', 'Minimum app version required'),
    ('max_delivery_distance_km', '50', 'Maximum delivery distance in kilometers'),
    ('escrow_hold_days', '14', 'Days to hold escrow before auto-release'),
    ('support_phone', '"+97412345678"', 'Customer support phone number'),
    ('support_email', '"support@onlycars.qa"', 'Customer support email');

ALTER TABLE public.delivery_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_config ENABLE ROW LEVEL SECURITY;
