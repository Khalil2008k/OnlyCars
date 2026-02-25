-- ============================================
-- OnlyCars Migration 008: Payments + Payouts + Bills
-- ============================================

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id),
    workshop_bill_id UUID,  -- FK added after workshop_bills created
    sadad_txn_id TEXT,
    amount NUMERIC(10,2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'QAR',
    type TEXT NOT NULL CHECK (type IN ('parts_escrow', 'workshop_labor', 'refund')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'captured', 'released', 'refunded', 'failed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.workshop_bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workshop_id UUID NOT NULL REFERENCES public.workshop_profiles(id),
    order_id UUID NOT NULL REFERENCES public.orders(id),
    consumer_id UUID NOT NULL REFERENCES public.users(id),
    labor_amount NUMERIC(10,2) NOT NULL,
    description_ar TEXT,
    photo_urls TEXT[] DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'submitted' CHECK (status IN ('submitted', 'approved', 'paid', 'disputed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add FK after workshop_bills exists
ALTER TABLE public.payments 
    ADD CONSTRAINT fk_payments_bill 
    FOREIGN KEY (workshop_bill_id) REFERENCES public.workshop_bills(id);

CREATE TABLE IF NOT EXISTS public.payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id),
    order_id UUID REFERENCES public.orders(id),
    recipient_type TEXT NOT NULL CHECK (recipient_type IN ('shop', 'driver', 'workshop', 'platform')),
    amount NUMERIC(10,2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'QAR',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    reference TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workshop_bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payouts ENABLE ROW LEVEL SECURITY;
