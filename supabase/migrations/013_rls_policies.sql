-- ============================================
-- OnlyCars Migration 013: RLS Policies
-- ============================================

-- ===== USERS =====
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ===== USER ROLES =====
CREATE POLICY "Users can view own roles" ON public.user_roles
    FOR SELECT USING (auth.uid() = user_id);

-- ===== ADDRESSES =====
CREATE POLICY "Users can CRUD own addresses" ON public.addresses
    FOR ALL USING (auth.uid() = user_id);

-- ===== WORKSHOPS =====
CREATE POLICY "Anyone can view workshops" ON public.workshop_profiles
    FOR SELECT USING (true);
CREATE POLICY "Workshop owner can update" ON public.workshop_profiles
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can create workshop" ON public.workshop_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ===== SHOPS =====
CREATE POLICY "Anyone can view shops" ON public.shop_profiles
    FOR SELECT USING (true);
CREATE POLICY "Shop owner can update" ON public.shop_profiles
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can create shop" ON public.shop_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ===== DRIVERS =====
CREATE POLICY "Drivers can view own profile" ON public.driver_profiles
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Driver owner can update" ON public.driver_profiles
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Authenticated users can create driver" ON public.driver_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ===== VEHICLES =====
CREATE POLICY "Users can CRUD own vehicles" ON public.vehicles
    FOR ALL USING (auth.uid() = user_id);

-- ===== DIAGNOSIS REPORTS =====
CREATE POLICY "Workshop creator can manage reports" ON public.diagnosis_reports
    FOR ALL USING (
        auth.uid() = consumer_id OR
        auth.uid() IN (SELECT user_id FROM public.workshop_profiles WHERE id = workshop_id)
    );

-- ===== DIAGNOSIS PARTS =====
CREATE POLICY "Access diagnosis parts via report" ON public.diagnosis_parts
    FOR SELECT USING (
        report_id IN (
            SELECT id FROM public.diagnosis_reports
            WHERE consumer_id = auth.uid()
            OR workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid())
        )
    );
CREATE POLICY "Workshop can insert diagnosis parts" ON public.diagnosis_parts
    FOR INSERT WITH CHECK (
        report_id IN (
            SELECT id FROM public.diagnosis_reports dr
            JOIN public.workshop_profiles wp ON dr.workshop_id = wp.id
            WHERE wp.user_id = auth.uid()
        )
    );

-- ===== PARTS CATALOG =====
CREATE POLICY "Anyone can view categories" ON public.part_categories
    FOR SELECT USING (true);
CREATE POLICY "Anyone can view active parts" ON public.parts
    FOR SELECT USING (is_active = true);
CREATE POLICY "Shop owner can manage parts" ON public.parts
    FOR ALL USING (
        shop_id IN (SELECT id FROM public.shop_profiles WHERE user_id = auth.uid())
    );
CREATE POLICY "Anyone can view part compatibility" ON public.part_vehicle_compat
    FOR SELECT USING (true);
CREATE POLICY "Shop owner can manage compatibility" ON public.part_vehicle_compat
    FOR ALL USING (
        part_id IN (
            SELECT p.id FROM public.parts p
            JOIN public.shop_profiles sp ON p.shop_id = sp.id
            WHERE sp.user_id = auth.uid()
        )
    );

-- ===== ORDERS =====
CREATE POLICY "Order participants can view" ON public.orders
    FOR SELECT USING (
        auth.uid() = consumer_id OR
        workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
        driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
    );
CREATE POLICY "Consumer can create order" ON public.orders
    FOR INSERT WITH CHECK (auth.uid() = consumer_id);
CREATE POLICY "Participants can update order" ON public.orders
    FOR UPDATE USING (
        auth.uid() = consumer_id OR
        workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
        driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
    );

-- ===== ORDER ITEMS =====
CREATE POLICY "Order items follow order access" ON public.order_items
    FOR SELECT USING (
        order_id IN (SELECT id FROM public.orders WHERE
            consumer_id = auth.uid() OR
            workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
            driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
        )
    );
CREATE POLICY "Consumer can insert order items" ON public.order_items
    FOR INSERT WITH CHECK (
        order_id IN (SELECT id FROM public.orders WHERE consumer_id = auth.uid())
    );

-- ===== ORDER STATUS LOG =====
CREATE POLICY "Order status log follows order access" ON public.order_status_log
    FOR SELECT USING (
        order_id IN (SELECT id FROM public.orders WHERE
            consumer_id = auth.uid() OR
            workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid()) OR
            driver_id IN (SELECT id FROM public.driver_profiles WHERE user_id = auth.uid())
        )
    );

-- ===== PAYMENTS =====
CREATE POLICY "Consumer can view own payments" ON public.payments
    FOR SELECT USING (
        order_id IN (SELECT id FROM public.orders WHERE consumer_id = auth.uid())
    );

-- ===== WORKSHOP BILLS =====
CREATE POLICY "Bill participants can view" ON public.workshop_bills
    FOR SELECT USING (
        auth.uid() = consumer_id OR
        workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid())
    );
CREATE POLICY "Workshop can create bill" ON public.workshop_bills
    FOR INSERT WITH CHECK (
        workshop_id IN (SELECT id FROM public.workshop_profiles WHERE user_id = auth.uid())
    );

-- ===== PAYOUTS =====
CREATE POLICY "Users can view own payouts" ON public.payouts
    FOR SELECT USING (auth.uid() = user_id);

-- ===== CHAT =====
CREATE POLICY "Participants can view chat rooms" ON public.chat_rooms
    FOR SELECT USING (auth.uid() = participant_1 OR auth.uid() = participant_2);
CREATE POLICY "Authenticated can create chat room" ON public.chat_rooms
    FOR INSERT WITH CHECK (auth.uid() = participant_1 OR auth.uid() = participant_2);
CREATE POLICY "Participants can view messages" ON public.chat_messages
    FOR SELECT USING (
        room_id IN (SELECT id FROM public.chat_rooms WHERE participant_1 = auth.uid() OR participant_2 = auth.uid())
    );
CREATE POLICY "Sender can insert message" ON public.chat_messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        room_id IN (SELECT id FROM public.chat_rooms WHERE participant_1 = auth.uid() OR participant_2 = auth.uid())
    );

-- ===== REVIEWS =====
CREATE POLICY "Anyone can view reviews" ON public.reviews
    FOR SELECT USING (true);
CREATE POLICY "Consumer can create review" ON public.reviews
    FOR INSERT WITH CHECK (auth.uid() = consumer_id);

-- ===== NOTIFICATIONS =====
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- ===== CAR HEALTH =====
CREATE POLICY "Vehicle owner can view health records" ON public.car_health_records
    FOR SELECT USING (
        vehicle_id IN (SELECT id FROM public.vehicles WHERE user_id = auth.uid())
    );

-- ===== CONFIG =====
CREATE POLICY "Anyone can read config" ON public.platform_config
    FOR SELECT USING (true);
CREATE POLICY "Anyone can read delivery zones" ON public.delivery_zones
    FOR SELECT USING (true);
