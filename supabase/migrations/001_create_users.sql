-- ============================================
-- OnlyCars Migration 001: Users Table
-- ============================================

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone TEXT NOT NULL,
    name TEXT,
    avatar_url TEXT,
    lang TEXT NOT NULL DEFAULT 'ar' CHECK (lang IN ('ar', 'en')),
    fcm_token TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE public.users IS 'User profiles — linked to Supabase Auth';
