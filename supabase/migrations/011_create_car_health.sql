-- ============================================
-- OnlyCars Migration 011: Car Health Vault
-- ============================================

CREATE TABLE IF NOT EXISTS public.car_health_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
    order_id UUID REFERENCES public.orders(id),
    event_type TEXT NOT NULL,
    description_ar TEXT,
    photo_urls TEXT[] DEFAULT '{}',
    hash TEXT,
    previous_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.car_health_records ENABLE ROW LEVEL SECURITY;
