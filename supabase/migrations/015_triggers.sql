-- ============================================
-- OnlyCars Migration 015: Triggers
-- ============================================

-- 1. Auto-update updated_at on all mutable tables
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_workshops_updated_at BEFORE UPDATE ON public.workshop_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_shops_updated_at BEFORE UPDATE ON public.shop_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_drivers_updated_at BEFORE UPDATE ON public.driver_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_vehicles_updated_at BEFORE UPDATE ON public.vehicles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_diagnosis_updated_at BEFORE UPDATE ON public.diagnosis_reports
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_parts_updated_at BEFORE UPDATE ON public.parts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2. Recalculate workshop avg_rating on review INSERT
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

CREATE TRIGGER trg_review_avg AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.recalculate_workshop_rating();

-- 3. Auto-log order status changes
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

CREATE TRIGGER trg_order_status_log AFTER UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.log_order_status_change();

-- 4. Decrement stock when order confirmed
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

CREATE TRIGGER trg_stock_decrement AFTER UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.decrement_stock_on_confirm();

-- 5. Update chat room last_message on new message
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

CREATE TRIGGER trg_chat_last_msg AFTER INSERT ON public.chat_messages
    FOR EACH ROW EXECUTE FUNCTION public.update_chat_room_last_message();

-- 6. Auto-create user profile on auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, phone, lang)
    VALUES (NEW.id, NEW.phone, 'ar');
    
    -- Default role: consumer
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'consumer');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
