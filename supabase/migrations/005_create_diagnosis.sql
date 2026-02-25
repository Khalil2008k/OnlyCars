-- ============================================
-- OnlyCars Migration 005: Diagnosis
-- ============================================

CREATE TABLE IF NOT EXISTS public.diagnosis_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workshop_id UUID NOT NULL REFERENCES public.workshop_profiles(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
    consumer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    issue_description_ar TEXT NOT NULL,
    photo_urls TEXT[] DEFAULT '{}',
    labor_quote NUMERIC(10,2),
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'negotiating', 'approved', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.diagnosis_parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID NOT NULL REFERENCES public.diagnosis_reports(id) ON DELETE CASCADE,
    part_name_ar TEXT NOT NULL,
    part_number TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    notes TEXT
);

ALTER TABLE public.diagnosis_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diagnosis_parts ENABLE ROW LEVEL SECURITY;
