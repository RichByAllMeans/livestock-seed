-- DEV FIXTURES — fake data for local development only. Never load in production.
-- Fixed UUID prefixes + ON CONFLICT make this safe to re-run.

-- Tenant --------------------------------------------------------------------
INSERT INTO tenants (id, name, subscription_plan, subscription_status)
VALUES ('00000000-0000-0000-0000-000000000001', 'Green Acres Demo', 'trial', 'active')
ON CONFLICT DO NOTHING;

-- Users (password for all: ChangeMe123) -------------------------------------
INSERT INTO users (id, tenant_id, email, password_hash, full_name, phone)
VALUES
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001',
   'owner@demo.local',   crypt('ChangeMe123', gen_salt('bf')), 'Demo Owner',   '+254700000001'),
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001',
   'manager@demo.local', crypt('ChangeMe123', gen_salt('bf')), 'Demo Manager', '+254700000002'),
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000001',
   'worker@demo.local',  crypt('ChangeMe123', gen_salt('bf')), 'Demo Worker',  '+254700000003'),
  ('00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000001',
   'vet@demo.local',     crypt('ChangeMe123', gen_salt('bf')), 'Dr. Otieno',   '+254700000004')
ON CONFLICT (tenant_id, email) DO NOTHING;

INSERT INTO user_roles (user_id, role_id) VALUES
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000100'),
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000101'),
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000102'),
  ('00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000103')
ON CONFLICT DO NOTHING;

-- Groups (nesting demo: herd -> pen) ----------------------------------------
INSERT INTO groups (id, tenant_id, name, type, parent_group_id, capacity, location, description) VALUES
  ('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000001',
   'Breeding Herd', 'herd', NULL, 50, 'North paddock', 'All breeding females'),
  ('00000000-0000-0000-0000-000000000202', '00000000-0000-0000-0000-000000000001',
   'Milking Pen', 'pen', '00000000-0000-0000-0000-000000000201', 20, 'Barn A', 'Lactating cows')
ON CONFLICT DO NOTHING;

-- Animals (one dam -> calf lineage, plus a mortality case) -------------------
INSERT INTO animals
  (id, tenant_id, tag_number, name, species, breed_id, sex, date_of_birth, origin,
   origin_source, current_group_id, acquisition_date, acquisition_cost, status, created_by)
SELECT '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000001',
       'GA-001', 'Bella', 'cattle', b.id, 'female', '2022-03-01', 'purchased',
       'Nakuru Dairy Farm', '00000000-0000-0000-0000-000000000201',
       '2022-03-15', 85000.00, 'active', '00000000-0000-0000-0000-000000000011'
FROM breeds b WHERE b.name = 'Friesian' AND b.tenant_id IS NULL
ON CONFLICT (tenant_id, tag_number) DO NOTHING;

INSERT INTO animals
  (id, tenant_id, tag_number, name, species, breed_id, sex, date_of_birth, origin,
   origin_source, current_group_id, acquisition_date, acquisition_cost, status, created_by)
SELECT '00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000001',
       'GA-002', 'Rocky', 'cattle', b.id, 'male', '2021-06-15', 'local',
       'Nakuru livestock market', '00000000-0000-0000-0000-000000000201',
       '2021-07-01', 60000.00, 'active', '00000000-0000-0000-0000-000000000011'
FROM breeds b WHERE b.name = 'Boran' AND b.tenant_id IS NULL
ON CONFLICT (tenant_id, tag_number) DO NOTHING;

INSERT INTO animals
  (id, tenant_id, tag_number, name, species, sex, date_of_birth, origin,
   current_group_id, dam_id, sire_id, status, created_by)
VALUES ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000001',
        'GA-003', 'Junior', 'cattle', 'male', '2024-01-10', 'newborn',
        '00000000-0000-0000-0000-000000000202',
        '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000102',
        'active', '00000000-0000-0000-0000-000000000011')
ON CONFLICT (tenant_id, tag_number) DO NOTHING;

INSERT INTO animals
  (id, tenant_id, tag_number, name, species, breed_id, sex, date_of_birth, origin,
   current_group_id, status, created_by)
SELECT '00000000-0000-0000-0000-000000000104', '00000000-0000-0000-0000-000000000001',
       'GA-004', 'Luna', 'cattle', b.id, 'female', '2023-09-05', 'born_on_farm',
       '00000000-0000-0000-0000-000000000201', 'dead', '00000000-0000-0000-0000-000000000011'
FROM breeds b WHERE b.name = 'Ayrshire' AND b.tenant_id IS NULL
ON CONFLICT (tenant_id, tag_number) DO NOTHING;

-- Group membership + consolidated history -----------------------------------
INSERT INTO animal_group_history (id, tenant_id, animal_id, group_id, start_date, reason, recorded_by)
VALUES
  ('00000000-0000-0000-0000-000000000716', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000201',
   '2022-03-15', 'Initial herd assignment', '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0000-000000000717', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000202',
   '2024-01-10', 'Newborn pen', '00000000-0000-0000-0000-000000000011')
ON CONFLICT DO NOTHING;

INSERT INTO animal_history_log (id, tenant_id, animal_id, event_type, event_date, weight_kg, recorded_by, notes)
VALUES
  ('00000000-0000-0000-0000-000000000710', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000101', 'weight', '2026-06-01 08:00+03', 470.00,
   '00000000-0000-0000-0000-000000000011', 'Routine weighing'),
  ('00000000-0000-0000-0000-000000000711', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000101', 'weight', '2026-09-01 08:00+03', 485.00,
   '00000000-0000-0000-0000-000000000011', 'Routine weighing'),
  ('00000000-0000-0000-0000-000000000718', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000103', 'weight', '2026-09-01 08:00+03', 210.00,
   '00000000-0000-0000-0000-000000000011', 'Routine weighing')
ON CONFLICT DO NOTHING;

-- Workers (worker + vet) ----------------------------------------------------
INSERT INTO workers
  (id, tenant_id, user_id, full_name, phone, email, role, role_title, hired_date, salary, notes, is_legacy)
VALUES
  ('00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000012', 'Demo Worker', '+254700000003',
   'worker@demo.local', 'worker', 'Herdsman', '2025-01-15', 30000.00, 'General herd duties', false),
  ('00000000-0000-0000-0000-000000000302', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000013', 'Dr. Otieno', '+254700000004',
   'vet@demo.local', 'vet', 'Veterinarian', '2024-02-01', 65000.00, 'Attending veterinarian', false)
ON CONFLICT (id) DO NOTHING;

-- Medications ---------------------------------------------------------------
INSERT INTO medications
  (id, tenant_id, name, type, manufacturer, unit, cost_per_unit,
   withdrawal_period_meat_days, withdrawal_period_milk_days, current_stock, notes)
VALUES
  ('00000000-0000-0000-0000-000000000601', '00000000-0000-0000-0000-000000000001',
   'FMD Vaccine', 'vaccine', 'Kenya Vet', 'ml', 750.00, 0, 0, 50.00, 'Annual FMD booster'),
  ('00000000-0000-0000-0000-000000000602', '00000000-0000-0000-0000-000000000001',
   'Albendazole', 'dewormer', 'AgriVet', 'ml', 80.00, 14, 4, 200.00, 'Broad-spectrum dewormer')
ON CONFLICT DO NOTHING;

-- Health (append-only) ------------------------------------------------------
INSERT INTO health_records
  (id, tenant_id, animal_id, event_type, occurred_at, diagnosis, treatment, medication,
   dosage, vet_name, cost, record_status, next_due_date, withdrawal_end_date,
   medication_id, vet_id, recorded_by)
VALUES
  ('00000000-0000-0000-0000-000000000651', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000101', 'vaccination', '2026-08-01 09:00+03',
   'FMD prophylaxis', 'Administered 2ml subcutaneous', 'FMD Vaccine', '2ml', 'Dr. Otieno',
   1500.00, 'completed', '2027-08-01', '2026-08-01',
   '00000000-0000-0000-0000-000000000601', '00000000-0000-0000-0000-000000000302',
   '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0000-000000000652', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000102', 'deworming', '2026-08-10 09:00+03',
   'Routine deworming', 'Oral drench', 'Albendazole', '10ml', 'Dr. Otieno',
   800.00, 'completed', '2026-11-10', '2026-08-24',
   '00000000-0000-0000-0000-000000000602', '00000000-0000-0000-0000-000000000302',
   '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0000-000000000653', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000103', 'vaccination', now(),
   NULL, NULL, 'FMD Vaccine', '1ml', 'Dr. Otieno', NULL, 'scheduled',
   CURRENT_DATE + 5, NULL,
   '00000000-0000-0000-0000-000000000601', '00000000-0000-0000-0000-000000000302',
   '00000000-0000-0000-0000-000000000011')
ON CONFLICT (id) DO NOTHING;

-- Mortality -----------------------------------------------------------------
INSERT INTO mortality_log
  (id, tenant_id, animal_id, date_of_death, cause_of_death, diagnosed_by,
   necropsy_performed, disposal_method, notes)
VALUES
  ('00000000-0000-0000-0000-000000000605', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000104', '2026-09-20', 'Bloat',
   '00000000-0000-0000-0000-000000000302', true, 'burial', 'Found recumbent after grazing')
ON CONFLICT DO NOTHING;

-- Breeding lifecycle --------------------------------------------------------
INSERT INTO breeding_events
  (id, tenant_id, dam_id, sire_id, event_type, occurred_at, expected_due_date,
   offspring_count, breeding_method, breeding_status, actual_birth_date, notes, recorded_by)
VALUES
  ('00000000-0000-0000-0000-000000000613', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000102',
   'birth', '2024-01-10 06:00+03', '2024-01-10', 1,
   'natural', 'completed', '2024-01-10', 'Unassisted birth', '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0000-000000000614', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000102',
   'insemination', now() - interval '45 days', CURRENT_DATE + 235, NULL,
   'artificial_insemination', 'confirmed_pregnant', NULL, 'Pregnancy confirmed by scan',
   '00000000-0000-0000-0000-000000000011')
ON CONFLICT (id) DO NOTHING;

INSERT INTO birth_records
  (id, tenant_id, breeding_event_id, dam_id, birth_date, total_offspring, live_births, stillbirths, notes)
VALUES
  ('00000000-0000-0000-0000-000000000611', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000613', '00000000-0000-0000-0000-000000000101',
   '2024-01-10', 1, 1, 0, 'Single live male calf')
ON CONFLICT (id) DO NOTHING;

INSERT INTO offspring
  (id, tenant_id, birth_record_id, animal_id, outcome, birth_weight_kg, weaning_date, weaning_weight_kg, notes)
VALUES
  ('00000000-0000-0000-0000-000000000612', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000611', '00000000-0000-0000-0000-000000000103',
   'weaned', 32.00, '2024-07-10', 95.00, 'Weaned successfully')
ON CONFLICT (id) DO NOTHING;

-- Feed (legacy tables retained) + general inventory -------------------------
INSERT INTO feed_items (id, tenant_id, name, category, unit) VALUES
  ('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000001', 'Dairy Meal', 'concentrate', 'kg'),
  ('00000000-0000-0000-0000-000000000402', '00000000-0000-0000-0000-000000000001', 'Hay', 'roughage', 'bale')
ON CONFLICT (tenant_id, name) DO NOTHING;

INSERT INTO feed_inventory (tenant_id, feed_item_id, quantity_on_hand, reorder_level, unit_cost) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000401', 120.000, 50.000, 55.00),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000402', 8.000, 10.000, 300.00)
ON CONFLICT (tenant_id, feed_item_id) DO NOTHING;

INSERT INTO suppliers (id, tenant_id, name, contact_person, phone, email, address, notes) VALUES
  ('00000000-0000-0000-0000-000000000701', '00000000-0000-0000-0000-000000000001',
   'Nakuru Feeds Ltd', 'Jane Wanjiku', '+254711000222', 'sales@nakurufeeds.local',
   'Industrial Area, Nakuru', 'Reliable feed and vet supplier')
ON CONFLICT DO NOTHING;

-- 401/402 already exist from the feed backfill; 403 is a general-inventory demo.
INSERT INTO inventory_items
  (id, tenant_id, category_id, name, sku, unit, current_stock, reorder_level,
   reorder_quantity, unit_cost, preferred_supplier_id, storage_location)
VALUES
  ('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000901', 'Dairy Meal', 'FEED-DM', 'kg',
   120.00, 50.00, 100.00, 55.00, '00000000-0000-0000-0000-000000000701', 'Store 1'),
  ('00000000-0000-0000-0000-000000000402', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000901', 'Hay', 'FEED-HAY', 'bale',
   8.00, 10.00, 20.00, 300.00, '00000000-0000-0000-0000-000000000701', 'Hay shed'),
  ('00000000-0000-0000-0000-000000000403', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000902', 'Veterinary Antibiotic', 'MED-AB1', 'ml',
   0.00, 5.00, 20.00, 12.00, '00000000-0000-0000-0000-000000000701', 'Drug cabinet')
ON CONFLICT DO NOTHING;

-- Supply chain --------------------------------------------------------------
INSERT INTO purchase_orders
  (id, tenant_id, supplier_id, order_date, expected_delivery_date, received_date,
   status, total_cost, created_by, notes)
VALUES
  ('00000000-0000-0000-0000-000000000702', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000701', CURRENT_DATE - 10, CURRENT_DATE - 3,
   CURRENT_DATE - 2, 'received', 240.00, '00000000-0000-0000-0000-000000000011',
   'Antibiotic restock')
ON CONFLICT (id) DO NOTHING;

INSERT INTO purchase_order_items
  (id, tenant_id, purchase_order_id, inventory_item_id, quantity, unit_cost)
VALUES
  ('00000000-0000-0000-0000-000000000703', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000702', '00000000-0000-0000-0000-000000000403',
   20.00, 12.00)
ON CONFLICT (id) DO NOTHING;

INSERT INTO stock_transactions
  (id, tenant_id, inventory_item_id, transaction_type, quantity, transaction_date,
   related_group_id, performed_by, notes, source_system, source_id)
VALUES
  ('00000000-0000-0000-0000-000000000704', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000403', 'purchase', 20.00, now() - interval '2 days',
   '00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000011',
   'Received PO-0001', 'seed', 'seed-st-001')
ON CONFLICT DO NOTHING;

-- Finance -------------------------------------------------------------------
INSERT INTO invoices
  (id, tenant_id, invoice_number, customer_name, customer_contact, issue_date, due_date,
   total_amount, status, notes, created_by)
VALUES
  ('00000000-0000-0000-0000-000000000501', '00000000-0000-0000-0000-000000000001',
   'INV-0001', 'Nairobi Dairy Co-op', '+254711000111', CURRENT_DATE, CURRENT_DATE + 30,
   45000.00, 'partial', 'September milk delivery', '00000000-0000-0000-0000-000000000011')
ON CONFLICT (tenant_id, invoice_number) DO NOTHING;

INSERT INTO invoice_items (id, invoice_id, description, quantity, unit_price) VALUES
  ('00000000-0000-0000-0000-000000000502', '00000000-0000-0000-0000-000000000501',
   'Milk (litres)', 900, 50.00)
ON CONFLICT (id) DO NOTHING;

INSERT INTO payments
  (id, tenant_id, invoice_id, payment_date, amount, payment_method, reference_number,
   recorded_by, notes)
VALUES
  ('00000000-0000-0000-0000-000000000705', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000501', CURRENT_DATE, 20000.00, 'mpesa',
   'MPESA-001', '00000000-0000-0000-0000-000000000011', 'First installment')
ON CONFLICT (id) DO NOTHING;

INSERT INTO transactions
  (id, tenant_id, txn_type, amount, category, category_code, description,
   occurred_at, related_invoice_id, related_animal_id, payment_method, recorded_by)
VALUES
  ('00000000-0000-0000-0000-000000000714', '00000000-0000-0000-0000-000000000001',
   'income', 20000.00, 'milk_sales', 'produce_sale', 'Payment against INV-0001',
   now(), '00000000-0000-0000-0000-000000000501', NULL, 'mpesa',
   '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0000-000000000715', '00000000-0000-0000-0000-000000000001',
   'expense', 1500.00, 'veterinary', 'vet_expense', 'FMD vaccine for Bella',
   now(), NULL, '00000000-0000-0000-0000-000000000101', 'cash',
   '00000000-0000-0000-0000-000000000011')
ON CONFLICT (id) DO NOTHING;

INSERT INTO budgets
  (id, tenant_id, name, category, category_code, period_start, period_end, planned_amount, notes)
VALUES
  ('00000000-0000-0000-0000-000000000713', '00000000-0000-0000-0000-000000000001',
   'Quarterly feed budget', 'feed', 'feed_purchase',
   date_trunc('quarter', CURRENT_DATE)::date,
   (date_trunc('quarter', CURRENT_DATE) + interval '3 months - 1 day')::date,
   30000.00, 'Feed and forage purchases')
ON CONFLICT (id) DO NOTHING;

-- Workforce -----------------------------------------------------------------
INSERT INTO attendance
  (tenant_id, worker_id, work_date, status, check_in, check_out,
   recorded_by, acknowledged_by, acknowledged_at)
VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000301',
   CURRENT_DATE, 'present', now(), now(), '00000000-0000-0000-0000-000000000011',
   '00000000-0000-0000-0000-000000000012', now())
ON CONFLICT (tenant_id, worker_id, work_date) DO NOTHING;

INSERT INTO work_schedules
  (id, tenant_id, worker_id, shift_date, start_time, end_time, role_for_shift, notes)
VALUES
  ('00000000-0000-0000-0000-000000000706', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000301', CURRENT_DATE, '06:00', '14:00',
   'Herdsman', 'Morning milking and feeding')
ON CONFLICT (id) DO NOTHING;

INSERT INTO task_assignments
  (id, tenant_id, worker_id, task_title, description, related_group_id,
   assigned_by, due_date, status, priority)
VALUES
  ('00000000-0000-0000-0000-000000000707', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000301', 'Check water troughs',
   'Verify all troughs are clean and full', '00000000-0000-0000-0000-000000000201',
   '00000000-0000-0000-0000-000000000011', CURRENT_DATE + 1, 'pending', 'medium')
ON CONFLICT (id) DO NOTHING;

-- Notifications / alert rules ----------------------------------------------
INSERT INTO notifications
  (id, tenant_id, recipient_user_id, channel, type, title, subject, body,
   priority, status, related_entity_type, related_entity_id, scheduled_at)
VALUES
  ('00000000-0000-0000-0000-000000000708', '00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000012', 'in_app', 'health',
   'Vaccination due for Junior', 'Vaccination due',
   'GA-003 Junior is due for an FMD booster in 5 days.', 'high', 'pending',
   'health_records', '00000000-0000-0000-0000-000000000653', now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO alert_rules
  (id, tenant_id, name, event_type, channel, lead_time_days, is_active,
   recipient_role, title_template, body_template, severity)
VALUES
  ('00000000-0000-0000-0000-000000000720', '00000000-0000-0000-0000-000000000001',
   'Vaccination due', 'vaccination_due', 'sms', 3, true, 'vet',
   'Vaccination due: {{animal}}', '{{animal}} is due for {{event}} on {{date}}.', 'high'),
  ('00000000-0000-0000-0000-000000000721', '00000000-0000-0000-0000-000000000001',
   'Low stock', 'low_stock', 'in_app', 0, true, 'manager',
   'Low stock: {{item}}', '{{item}} is at {{quantity}} {{unit}} (reorder at {{reorder_level}}).', 'medium')
ON CONFLICT (id) DO NOTHING;
