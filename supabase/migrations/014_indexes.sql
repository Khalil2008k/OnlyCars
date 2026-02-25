-- ============================================
-- OnlyCars Migration 014: Indexes
-- ============================================

-- Parts marketplace
CREATE INDEX idx_parts_shop_active ON public.parts(shop_id, is_active);
CREATE INDEX idx_parts_category ON public.parts(category_id);
CREATE INDEX idx_parts_condition ON public.parts(condition);
CREATE INDEX idx_parts_price ON public.parts(price);

-- Compatibility search
CREATE INDEX idx_compat_make_model ON public.part_vehicle_compat(make, model);
CREATE INDEX idx_compat_part ON public.part_vehicle_compat(part_id);

-- Order queries
CREATE INDEX idx_orders_consumer ON public.orders(consumer_id, status);
CREATE INDEX idx_orders_workshop ON public.orders(workshop_id, status);
CREATE INDEX idx_orders_driver ON public.orders(driver_id, status);
CREATE INDEX idx_order_items_order ON public.order_items(order_id);

-- Geo queries
CREATE INDEX idx_workshops_geo ON public.workshop_profiles(lat, lng);
CREATE INDEX idx_shops_geo ON public.shop_profiles(lat, lng);

-- Chat performance
CREATE INDEX idx_chat_room ON public.chat_messages(room_id, created_at);
CREATE INDEX idx_chat_rooms_p1 ON public.chat_rooms(participant_1);
CREATE INDEX idx_chat_rooms_p2 ON public.chat_rooms(participant_2);

-- Notifications
CREATE INDEX idx_notifications_user ON public.notifications(user_id, is_read);

-- Reviews
CREATE INDEX idx_reviews_workshop ON public.reviews(workshop_id);

-- Status log
CREATE INDEX idx_status_log_order ON public.order_status_log(order_id, created_at);

-- Health records
CREATE INDEX idx_health_vehicle ON public.car_health_records(vehicle_id, created_at);

-- Diagnosis
CREATE INDEX idx_diagnosis_consumer ON public.diagnosis_reports(consumer_id);
CREATE INDEX idx_diagnosis_workshop ON public.diagnosis_reports(workshop_id);
