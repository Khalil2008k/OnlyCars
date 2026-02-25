-- ============================================
-- OnlyCars Migration 002: Roles + Addresses
-- ============================================

-- Multi-role support: a user can be consumer + workshop + shop owner
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('consumer', 'workshop', 'driver', 'shop', 'admin')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Qatar addressing: zone/street/building
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    label TEXT NOT NULL DEFAULT 'بيت' CHECK (label IN ('بيت', 'ورشة', 'محل', 'أخرى')),
    zone TEXT,
    street TEXT,
    building TEXT,
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE public.user_roles IS 'Junction table for multi-role users';
COMMENT ON TABLE public.addresses IS 'Qatar-style addresses with zone/street/building';
