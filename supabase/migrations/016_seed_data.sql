-- ============================================
-- OnlyCars Migration 016: Seed Data
-- ============================================
-- NOTE: This seed inserts test data for development.
-- Fake UUIDs used for testing — real data comes from auth.users in production.

-- Part categories
INSERT INTO public.part_categories (id, name_ar, name_en, icon, sort_order) VALUES
    ('c0000001-0000-0000-0000-000000000001', 'فلاتر', 'Filters', 'filter', 1),
    ('c0000001-0000-0000-0000-000000000002', 'فرامل', 'Brakes', 'brake', 2),
    ('c0000001-0000-0000-0000-000000000003', 'زيوت', 'Oils', 'oil', 3),
    ('c0000001-0000-0000-0000-000000000004', 'إطارات', 'Tires', 'tire', 4),
    ('c0000001-0000-0000-0000-000000000005', 'كهرباء', 'Electrical', 'electric', 5),
    ('c0000001-0000-0000-0000-000000000006', 'تكييف', 'AC', 'ac', 6),
    ('c0000001-0000-0000-0000-000000000007', 'بودي', 'Body', 'body', 7),
    ('c0000001-0000-0000-0000-000000000008', 'محرك', 'Engine', 'engine', 8);

-- Delivery zones
INSERT INTO public.delivery_zones (name_ar, name_en, base_fee, per_km_fee) VALUES
    ('الدوحة', 'Doha', 15.00, 2.00),
    ('الوكرة', 'Al Wakrah', 20.00, 2.50),
    ('الخور', 'Al Khor', 25.00, 3.00),
    ('الريان', 'Al Rayyan', 15.00, 2.00),
    ('أم صلال', 'Umm Salal', 20.00, 2.50);
