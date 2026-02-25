-- ============================================
-- OnlyCars — ALL MIGRATIONS COMBINED
-- Paste this entire file into Supabase SQL Editor
-- ============================================

-- ====== 001: USERS ======
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

-- ====== 002: ROLES + ADDRESSES ======
CREATE TABLE IF NOT EXISTS public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('consumer', 'workshop', 'driver', 'shop', 'admin')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, role)
);
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

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

-- ====== 003: PROVIDER PROFILES ======
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

-- ====== 004: VEHICLES ======
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    vin TEXT,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    plate_number TEXT,
    color TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

-- ====== 005: DIAGNOSIS ======
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

-- ====== 006: PARTS CATALOG ======
CREATE TABLE IF NOT EXISTS public.part_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_ar TEXT NOT NULL,
    name_en TEXT,
    icon TEXT,
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES public.shop_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.part_categories(id) ON DELETE SET NULL,
    name_ar TEXT NOT NULL,
    name_en TEXT,
    description_ar TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_qty INTEGER NOT NULL DEFAULT 0,
    condition TEXT NOT NULL DEFAULT 'aftermarket' CHECK (condition IN ('OEM', 'aftermarket', 'used')),
    image_urls TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.part_vehicle_compat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    part_id UUID NOT NULL REFERENCES public.parts(id) ON DELETE CASCADE,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year_from INTEGER,
    year_to INTEGER
);

ALTER TABLE public.part_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.part_vehicle_compat ENABLE ROW LEVEL SECURITY;

-- ====== 007: ORDERS ======
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES public.users(id),
    workshop_id UUID REFERENCES public.workshop_profiles(id),
    driver_id UUID REFERENCES public.driver_profiles(id),
    workshop_code TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
        'pending', 'confirmed', 'preparing', 'ready_for_pickup',
        'picked_up', 'in_transit', 'delivered', 'completed',
        'cancelled', 'disputed'
    )),
    parts_total NUMERIC(10,2) NOT NULL DEFAULT 0,
    delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0,
    platform_fee NUMERIC(10,2) NOT NULL DEFAULT 0,
    total NUMERIC(10,2) NOT NULL DEFAULT 0,
    escrow_status TEXT DEFAULT 'none' CHECK (escrow_status IN ('none', 'held', 'partial_release', 'released', 'refunded')),
    delivery_address_id UUID REFERENCES public.addresses(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    part_id UUID NOT NULL REFERENCES public.parts(id),
    shop_id UUID NOT NULL REFERENCES public.shop_profiles(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.order_status_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    old_status TEXT,
    new_status TEXT NOT NULL,
    changed_by UUID REFERENCES public.users(id),
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_log ENABLE ROW LEVEL SECURITY;

-- ====== 008: PAYMENTS ======
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id),
    workshop_bill_id UUID,
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

-- ====== 009: CHAT ======
CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_1 UUID NOT NULL REFERENCES public.users(id),
    participant_2 UUID NOT NULL REFERENCES public.users(id),
    order_id UUID REFERENCES public.orders(id),
    last_message TEXT,
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (participant_1, participant_2, order_id)
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.users(id),
    content TEXT,
    type TEXT NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'image', 'voice', 'report')),
    media_url TEXT,
    metadata JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- ====== 010: REVIEWS + NOTIFICATIONS ======
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES public.users(id),
    workshop_id UUID NOT NULL REFERENCES public.workshop_profiles(id),
    order_id UUID REFERENCES public.orders(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment_ar TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (consumer_id, order_id)
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title_ar TEXT NOT NULL,
    body_ar TEXT NOT NULL,
    type TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ====== 011: CAR HEALTH VAULT ======
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

-- ====== 012: CONFIG + DELIVERY ZONES ======
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

INSERT INTO public.platform_config (key, value, description) VALUES
    ('commission_rate', '"0.05"', 'Platform commission percentage (5%)'),
    ('min_app_version', '"1.0.0"', 'Minimum app version required'),
    ('max_delivery_distance_km', '50', 'Maximum delivery distance in kilometers'),
    ('escrow_hold_days', '14', 'Days to hold escrow before auto-release'),
    ('support_phone', '"+97412345678"', 'Customer support phone number'),
    ('support_email', '"support@onlycars.qa"', 'Customer support email');

ALTER TABLE public.delivery_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_config ENABLE ROW LEVEL SECURITY;

-- ====== 013: RLS POLICIES ======
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own roles" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can CRUD own addresses" ON public.addresses FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view workshops" ON public.workshop_profiles FOR SELECT USING (true);
CREATE POLICY "Workshop owner can update" ON public.workshop_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can create workshop" ON public.workshop_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can view shops" ON public.shop_profiles FOR SELECT USING (true);
CREATE POLICY "Shop owner can update" ON public.shop_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can create shop" ON public.shop_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Drivers can view own profile" ON public.driver_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Driver owner can update" ON public.driver_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can create driver" ON public.driver_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can CRUD own vehicles" ON public.vehicles FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Workshop creator can manage reports" ON public.diagnosis_reports FOR ALL USING (
    auth.uid() = consumer_id OR
    auth.uid() IN (SELECT wp.user_id FROM public.workshop_profiles wp WHERE wp.id = diagnosis_reports.workshop_id)
);

CREATE POLICY "Access diagnosis parts via report" ON public.diagnosis_parts FOR SELECT USING (
    report_id IN (
        SELECT dr.id FROM public.diagnosis_reports dr
        WHERE dr.consumer_id = auth.uid()
        OR dr.workshop_id IN (SELECT wp.id FROM public.workshop_profiles wp WHERE wp.user_id = auth.uid())
    )
);
CREATE POLICY "Workshop can insert diagnosis parts" ON public.diagnosis_parts FOR INSERT WITH CHECK (
    report_id IN (
        SELECT dr.id FROM public.diagnosis_reports dr
        JOIN public.workshop_profiles wp ON dr.workshop_id = wp.id
        WHERE wp.user_id = auth.uid()
    )
);

CREATE POLICY "Anyone can view categories" ON public.part_categories FOR SELECT USING (true);
CREATE POLICY "Anyone can view active parts" ON public.parts FOR SELECT USING (is_active = true);
CREATE POLICY "Shop owner can manage parts" ON public.parts FOR ALL USING (
    shop_id IN (SELECT id FROM public.shop_profiles WHERE user_id = auth.uid())
);
CREATE POLICY "Anyone can view part compatibility" ON public.part_vehicle_compat FOR SELECT USING (true);
CREATE POLICY "Shop owner can manage compatibility" ON public.part_vehicle_compat FOR ALL USING (
    part_id IN (
        SELECT p.id FROM public.parts p
        JOIN public.shop_profiles sp ON p.shop_id = sp.id
        WHERE sp.user_id = auth.uid()
    )
);

CREATE POLICY "Order participants can view" ON public.orders FOR SELECT USING (
    auth.uid() = consumer_id OR
    workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
    driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
);
CREATE POLICY "Consumer can create order" ON public.orders FOR INSERT WITH CHECK (auth.uid() = consumer_id);
CREATE POLICY "Participants can update order" ON public.orders FOR UPDATE USING (
    auth.uid() = consumer_id OR
    workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
    driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
);

CREATE POLICY "Order items follow order access" ON public.order_items FOR SELECT USING (
    order_id IN (SELECT id FROM public.orders WHERE
        consumer_id = auth.uid() OR
        workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
        driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
    )
);
CREATE POLICY "Consumer can insert order items" ON public.order_items FOR INSERT WITH CHECK (
    order_id IN (SELECT id FROM public.orders WHERE consumer_id = auth.uid())
);

CREATE POLICY "Order status log follows order access" ON public.order_status_log FOR SELECT USING (
    order_id IN (SELECT id FROM public.orders WHERE
        consumer_id = auth.uid() OR
        workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
        driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
    )
);

CREATE POLICY "Consumer can view own payments" ON public.payments FOR SELECT USING (
    order_id IN (SELECT id FROM public.orders WHERE consumer_id = auth.uid())
);

CREATE POLICY "Bill participants can view" ON public.workshop_bills FOR SELECT USING (
    auth.uid() = consumer_id OR
    workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid())
);
CREATE POLICY "Workshop can create bill" ON public.workshop_bills FOR INSERT WITH CHECK (
    workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid())
);

CREATE POLICY "Users can view own payouts" ON public.payouts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Participants can view chat rooms" ON public.chat_rooms FOR SELECT USING (auth.uid() = participant_1 OR auth.uid() = participant_2);
CREATE POLICY "Authenticated can create chat room" ON public.chat_rooms FOR INSERT WITH CHECK (auth.uid() = participant_1 OR auth.uid() = participant_2);
CREATE POLICY "Participants can view messages" ON public.chat_messages FOR SELECT USING (
    room_id IN (SELECT id FROM public.chat_rooms WHERE participant_1 = auth.uid() OR participant_2 = auth.uid())
);
CREATE POLICY "Sender can insert message" ON public.chat_messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    room_id IN (SELECT id FROM public.chat_rooms WHERE participant_1 = auth.uid() OR participant_2 = auth.uid())
);

CREATE POLICY "Anyone can view reviews" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Consumer can create review" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = consumer_id);

CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Vehicle owner can view health records" ON public.car_health_records FOR SELECT USING (
    vehicle_id IN (SELECT id FROM public.vehicles WHERE user_id = auth.uid())
);

CREATE POLICY "Anyone can read config" ON public.platform_config FOR SELECT USING (true);
CREATE POLICY "Anyone can read delivery zones" ON public.delivery_zones FOR SELECT USING (true);

-- ====== 014: INDEXES ======
CREATE INDEX idx_parts_shop_active ON public.parts(shop_id, is_active);
CREATE INDEX idx_parts_category ON public.parts(category_id);
CREATE INDEX idx_parts_condition ON public.parts(condition);
CREATE INDEX idx_parts_price ON public.parts(price);
CREATE INDEX idx_compat_make_model ON public.part_vehicle_compat(make, model);
CREATE INDEX idx_compat_part ON public.part_vehicle_compat(part_id);
CREATE INDEX idx_orders_consumer ON public.orders(consumer_id, status);
CREATE INDEX idx_orders_workshop ON public.orders(workshop_id, status);
CREATE INDEX idx_orders_driver ON public.orders(driver_id, status);
CREATE INDEX idx_order_items_order ON public.order_items(order_id);
CREATE INDEX idx_workshops_geo ON public.workshop_profiles(lat, lng);
CREATE INDEX idx_shops_geo ON public.shop_profiles(lat, lng);
CREATE INDEX idx_chat_room ON public.chat_messages(room_id, created_at);
CREATE INDEX idx_chat_rooms_p1 ON public.chat_rooms(participant_1);
CREATE INDEX idx_chat_rooms_p2 ON public.chat_rooms(participant_2);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, is_read);
CREATE INDEX idx_reviews_workshop ON public.reviews(workshop_id);
CREATE INDEX idx_status_log_order ON public.order_status_log(order_id, created_at);
CREATE INDEX idx_health_vehicle ON public.car_health_records(vehicle_id, created_at);
CREATE INDEX idx_diagnosis_consumer ON public.diagnosis_reports(consumer_id);
CREATE INDEX idx_diagnosis_workshop ON public.diagnosis_reports(workshop_id);

-- ====== 015: TRIGGERS ======
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_workshops_updated_at BEFORE UPDATE ON public.workshop_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_shops_updated_at BEFORE UPDATE ON public.shop_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_drivers_updated_at BEFORE UPDATE ON public.driver_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_vehicles_updated_at BEFORE UPDATE ON public.vehicles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_diagnosis_updated_at BEFORE UPDATE ON public.diagnosis_reports FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_parts_updated_at BEFORE UPDATE ON public.parts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.recalculate_workshop_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.workshop_profiles
    SET
        avg_rating = (SELECT COALESCE(AVG(rating), 0) FROM public.reviews WHERE workshop_id = NEW.workshop_id),
        total_reviews = (SELECT COUNT(*) FROM public.reviews WHERE workshop_id = NEW.workshop_id)
    WHERE id = NEW.workshop_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_avg AFTER INSERT ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.recalculate_workshop_rating();

CREATE OR REPLACE FUNCTION public.log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.order_status_log (order_id, old_status, new_status, changed_by)
        VALUES (NEW.id, OLD.status, NEW.status, auth.uid());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_status_log AFTER UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.log_order_status_change();

CREATE OR REPLACE FUNCTION public.decrement_stock_on_confirm()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'confirmed' AND OLD.status = 'pending' THEN
        UPDATE public.parts p
        SET stock_qty = stock_qty - oi.quantity
        FROM public.order_items oi
        WHERE oi.order_id = NEW.id AND p.id = oi.part_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stock_decrement AFTER UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.decrement_stock_on_confirm();

CREATE OR REPLACE FUNCTION public.update_chat_room_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.chat_rooms
    SET last_message = NEW.content,
        last_message_at = NEW.created_at
    WHERE id = NEW.room_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_chat_last_msg AFTER INSERT ON public.chat_messages FOR EACH ROW EXECUTE FUNCTION public.update_chat_room_last_message();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, phone, lang)
    VALUES (NEW.id, NEW.phone, 'ar');
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'consumer');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ====== 016: SEED DATA ======
INSERT INTO public.part_categories (id, name_ar, name_en, icon, sort_order) VALUES
    ('c0000001-0000-0000-0000-000000000001', 'فلاتر', 'Filters', 'filter', 1),
    ('c0000001-0000-0000-0000-000000000002', 'فرامل', 'Brakes', 'brake', 2),
    ('c0000001-0000-0000-0000-000000000003', 'زيوت', 'Oils', 'oil', 3),
    ('c0000001-0000-0000-0000-000000000004', 'إطارات', 'Tires', 'tire', 4),
    ('c0000001-0000-0000-0000-000000000005', 'كهرباء', 'Electrical', 'electric', 5),
    ('c0000001-0000-0000-0000-000000000006', 'تكييف', 'AC', 'ac', 6),
    ('c0000001-0000-0000-0000-000000000007', 'بودي', 'Body', 'body', 7),
    ('c0000001-0000-0000-0000-000000000008', 'محرك', 'Engine', 'engine', 8);

INSERT INTO public.delivery_zones (name_ar, name_en, base_fee, per_km_fee) VALUES
    ('الدوحة', 'Doha', 15.00, 2.00),
    ('الوكرة', 'Al Wakrah', 20.00, 2.50),
    ('الخور', 'Al Khor', 25.00, 3.00),
    ('الريان', 'Al Rayyan', 15.00, 2.00),
    ('أم صلال', 'Umm Salal', 20.00, 2.50);

-- ============================================
-- ✅ ALL DONE — 25 tables, ~40 RLS policies,
--    21 indexes, 6 trigger functions, seed data
-- ============================================
