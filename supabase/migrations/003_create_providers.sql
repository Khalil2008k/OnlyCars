-- ============================================
-- OnlyCars Migration 003: Provider Profiles
-- ============================================

CREATE TABLE IF NOT EXISTS public.workshop_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.users(id) ON DELETE CASCADE,
    name_ar TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    description_ar TEXT,
    phone TEXT,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    zone TEXT,
    street TEXT,
    building TEXT,
    cover_photo_url TEXT,
    gallery_urls TEXT[] DEFAULT '{}',
    specialties TEXT[] DEFAULT '{}',
    working_hours TEXT DEFAULT '08:00-18:00',
    working_days TEXT DEFAULT 'Sun-Thu',
    avg_rating NUMERIC(2,1) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    total_jobs_completed INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    is_open_now BOOLEAN DEFAULT true,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.shop_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.users(id) ON DELETE CASCADE,
    name_ar TEXT NOT NULL,
    description_ar TEXT,
    phone TEXT,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    zone TEXT,
    cover_photo_url TEXT,
    gallery_urls TEXT[] DEFAULT '{}',
    brands TEXT[] DEFAULT '{}',
    avg_rating NUMERIC(2,1) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.driver_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.users(id) ON DELETE CASCADE,
    vehicle_type TEXT,
    vehicle_plate TEXT,
    license_url TEXT,
    is_available BOOLEAN DEFAULT false,
    current_lat DOUBLE PRECISION,
    current_lng DOUBLE PRECISION,
    total_deliveries INTEGER DEFAULT 0,
    avg_rating NUMERIC(2,1) DEFAULT 0,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.workshop_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_profiles ENABLE ROW LEVEL SECURITY;
