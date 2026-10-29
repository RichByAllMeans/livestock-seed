-- Reference data — idempotent. Safe to re-run after migrations.
-- System roles/categories use tenant_id = NULL (available to every tenant).

-- Permissions ---------------------------------------------------------------
INSERT INTO permissions (code, description) VALUES
  ('animals.read',    'View animals and lineage'),
  ('animals.write',   'Create/update animals'),
  ('health.read',     'View health history'),
  ('health.write',    'Record health events'),
  ('breeding.read',   'View breeding records'),
  ('breeding.write',  'Record breeding events'),
  ('inventory.read',  'View feed and general inventory'),
  ('inventory.write', 'Manage feed, stock and purchase orders'),
  ('finance.read',    'View financial data and reports'),
  ('finance.write',   'Record transactions, invoices and payments'),
  ('workforce.read',  'View workers and attendance'),
  ('workforce.write', 'Manage workers, schedules and tasks'),
  ('attendance.ack',  'Acknowledge own attendance record'),
  ('reports.read',    'Generate and export reports'),
  ('audit.read',      'View audit trail (owner/manager only)'),
  ('users.manage',    'Manage users and roles'),
  ('tenants.manage',  'Manage tenant/subscription settings')
ON CONFLICT (code) DO NOTHING;

-- System roles --------------------------------------------------------------
INSERT INTO roles (id, tenant_id, name, description) VALUES
  ('00000000-0000-0000-0000-000000000100', NULL, 'owner',   'Full access incl. audit trail'),
  ('00000000-0000-0000-0000-000000000101', NULL, 'manager', 'Operational access incl. audit trail'),
  ('00000000-0000-0000-0000-000000000102', NULL, 'worker',  'Limited operational access'),
  ('00000000-0000-0000-0000-000000000103', NULL, 'vet',     'Animal health and breeding access')
ON CONFLICT DO NOTHING;

-- Role → permission wiring --------------------------------------------------
-- owner: everything
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000100', id FROM permissions
ON CONFLICT DO NOTHING;

-- manager: everything except tenant/user administration
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000101', id FROM permissions
WHERE code NOT IN ('tenants.manage', 'users.manage')
ON CONFLICT DO NOTHING;

-- worker: read-only + own attendance acknowledgement
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000102', id FROM permissions
WHERE code IN ('animals.read', 'health.read', 'inventory.read',
               'workforce.read', 'attendance.ack')
ON CONFLICT DO NOTHING;

-- vet: health/breeding write, animal read, own attendance
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000103', id FROM permissions
WHERE code IN ('animals.read', 'health.read', 'health.write',
               'breeding.read', 'breeding.write', 'inventory.read',
               'reports.read', 'attendance.ack')
ON CONFLICT DO NOTHING;

-- System breeds (tenant_id = NULL) ------------------------------------------
INSERT INTO breeds (tenant_id, name, species) VALUES
  (NULL, 'Friesian',      'cattle'),
  (NULL, 'Ayrshire',      'cattle'),
  (NULL, 'Boran',         'cattle'),
  (NULL, 'Sahiwal',       'cattle'),
  (NULL, 'Zebu',          'cattle'),
  (NULL, 'Dorper',        'sheep'),
  (NULL, 'Galla',         'goat')
ON CONFLICT DO NOTHING;

-- System inventory categories (tenant_id = NULL) ----------------------------
INSERT INTO inventory_categories (id, tenant_id, name, description) VALUES
  ('00000000-0000-0000-0000-000000000901', NULL, 'Feed',      'Feed, forage and supplements'),
  ('00000000-0000-0000-0000-000000000902', NULL, 'Medication','Vaccines, antibiotics and dewormers'),
  ('00000000-0000-0000-0000-000000000903', NULL, 'Equipment', 'Tools and equipment'),
  ('00000000-0000-0000-0000-000000000904', NULL, 'Material',  'Farm materials and consumables'),
  ('00000000-0000-0000-0000-000000000905', NULL, 'Other',     'Uncategorised stock')
ON CONFLICT DO NOTHING;
