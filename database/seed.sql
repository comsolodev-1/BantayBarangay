-- =====================================================================
-- Bantay Barangay: seed data
-- Import AFTER schema.sql, once, into a fresh database.
--
-- Part 1 (always loaded)
--   * 1 Super Admin account
--   * the 15 barangays of Talisay, Camarines Norte
--   * 1 Barangay Admin account per barangay
--   (the three roles are already created by schema.sql)
--
-- Part 2 (optional demo data, controlled by @load_demo_data below)
--   * 5 demo activities, each with one reporting period
--   * 50 activity assignments and 40 sample submissions
--     (Confirmed / Pending / Denied, on-time and late)
--   Deadlines are relative to the day you import, so the demo always
--   looks current. The 40 sample PDFs it points to are
--   App_Data/uploads/submissions/demo100-*.pdf.
--   Every demo activity has remarks = 'BB-SAMPLE-100-v1', which is how
--   you find (and remove) it later.
--
-- Default logins. CHANGE THESE before sharing the installation:
--   superadmin      /  Admin@12345
--   brgy_*          /  Barangay@123
--
-- All account holders are fictional demonstration identities.
-- Barangay codes (TAL-01 ...) are placeholders. Replace them with the
-- official codes if you have them; every table that points to a barangay
-- uses ON UPDATE CASCADE, so changing a code is safe.
-- =====================================================================

USE bantay_barangay;

-- Match SQL literals and temporary demo data to the selected database.
SET SESSION collation_connection = @@collation_database;

-- 1 = also load the demo activities and submissions, 0 = accounts and barangays only.
SET @load_demo_data = 1;

START TRANSACTION;

-- ---------------------------------------------------------------------
-- Part 1a. Super Admin
-- ---------------------------------------------------------------------
SET @role_super  = (SELECT role_id FROM roles WHERE role_name = 'Super Admin');
SET @role_brgy   = (SELECT role_id FROM roles WHERE role_name = 'Barangay Admin');

INSERT INTO users (username, password_hash, role_id, account_status, password_changed) VALUES
  ('superadmin', '$2b$11$7WjR3re9sWDM6zYRKRDOi.T29Kr5rRdoaqaaBUrm29g0tzLJVdJlu', @role_super, 'Active', NOW());

SET @super_id = LAST_INSERT_ID();

-- ---------------------------------------------------------------------
-- Part 1b. Barangays
-- ---------------------------------------------------------------------
INSERT INTO barangays (barangay_code, barangay_name, municipality, province, status) VALUES
  ('TAL-01', 'Binanuaan',     'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-02', 'Caawigan',      'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-03', 'Cahabaan',      'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-04', 'Calintaan',     'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-05', 'Del Carmen',    'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-06', 'Gabon',         'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-07', 'Itomang',       'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-08', 'Poblacion',     'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-09', 'San Francisco', 'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-10', 'San Isidro',    'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-11', 'San Jose',      'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-12', 'San Nicolas',   'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-13', 'Santa Cruz',    'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-14', 'Santa Elena',   'Talisay', 'Camarines Norte', 'Active'),
  ('TAL-15', 'Santo Niño',    'Talisay', 'Camarines Norte', 'Active');

-- ---------------------------------------------------------------------
-- Part 1c. One Barangay Admin per barangay (same starter password)
-- ---------------------------------------------------------------------
SET @brgy_hash = '$2b$11$mkdU6LTfqVDTPAwkgmI0WeHApugqvE2HCoULN7k65d1d9njYqEucu';

INSERT INTO users (username, password_hash, role_id, barangay_code, account_status, created_by) VALUES
  ('brgy_binanuaan',     @brgy_hash, @role_brgy, 'TAL-01', 'Active', @super_id),
  ('brgy_caawigan',      @brgy_hash, @role_brgy, 'TAL-02', 'Active', @super_id),
  ('brgy_cahabaan',      @brgy_hash, @role_brgy, 'TAL-03', 'Active', @super_id),
  ('brgy_calintaan',     @brgy_hash, @role_brgy, 'TAL-04', 'Active', @super_id),
  ('brgy_del_carmen',    @brgy_hash, @role_brgy, 'TAL-05', 'Active', @super_id),
  ('brgy_gabon',         @brgy_hash, @role_brgy, 'TAL-06', 'Active', @super_id),
  ('brgy_itomang',       @brgy_hash, @role_brgy, 'TAL-07', 'Active', @super_id),
  ('brgy_poblacion',     @brgy_hash, @role_brgy, 'TAL-08', 'Active', @super_id),
  ('brgy_san_francisco', @brgy_hash, @role_brgy, 'TAL-09', 'Active', @super_id),
  ('brgy_san_isidro',    @brgy_hash, @role_brgy, 'TAL-10', 'Active', @super_id),
  ('brgy_san_jose',      @brgy_hash, @role_brgy, 'TAL-11', 'Active', @super_id),
  ('brgy_san_nicolas',   @brgy_hash, @role_brgy, 'TAL-12', 'Active', @super_id),
  ('brgy_santa_cruz',    @brgy_hash, @role_brgy, 'TAL-13', 'Active', @super_id),
  ('brgy_santa_elena',   @brgy_hash, @role_brgy, 'TAL-14', 'Active', @super_id),
  ('brgy_santo_nino',    @brgy_hash, @role_brgy, 'TAL-15', 'Active', @super_id);

-- Link each barangay back to its account (barangays.user_id).
UPDATE barangays b
  JOIN users u ON u.barangay_code = b.barangay_code
   SET b.user_id = u.user_id;


-- ---------------------------------------------------------------------
-- Part 2. Optional demo data (skipped entirely when @load_demo_data = 0)
-- ---------------------------------------------------------------------
SET @demo_batch = 'BB-SAMPLE-100-v1';

CREATE TEMPORARY TABLE demo_topic (n INT PRIMARY KEY, title VARCHAR(150) NOT NULL);
INSERT INTO demo_topic (n, title) VALUES
  (1, '[Demo] Clean-up report'),
  (2, '[Demo] Council meeting summary'),
  (3, '[Demo] Community outreach report'),
  (4, '[Demo] Facility inspection'),
  (5, '[Demo] Waste collection report');

-- Ten assignment slots per activity. Slots 1-8 also get a submission.
CREATE TEMPORARY TABLE demo_slot (slot INT PRIMARY KEY);
INSERT INTO demo_slot (slot) VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

-- Which barangay each (activity, slot) pair is assigned to: TAL-01 .. TAL-15, rotating.
CREATE TEMPORARY TABLE demo_assignment AS
SELECT t.n, s.slot,
       CONCAT('TAL-', LPAD(1 + MOD((t.n - 1) * 3 + s.slot - 1, 15), 2, '0')) AS barangay_code
FROM demo_topic t CROSS JOIN demo_slot s;

-- 5 activities, due 4 to 8 days ago.
INSERT INTO activities (activity_name, frequency, default_deadline, created_by, remarks)
SELECT t.title, 'Monthly', DATE_SUB(CURDATE(), INTERVAL (t.n + 3) DAY), @super_id, @demo_batch
FROM demo_topic t
WHERE @load_demo_data = 1;

-- One monthly reporting period per demo activity.
INSERT INTO reporting_period
  (activity_id, period_type, period_name, period_year, period_number,
   start_date, end_date, submission_deadline, created_by)
SELECT a.activity_id, 'Monthly',
       DATE_FORMAT(a.default_deadline, '%M %Y'),
       YEAR(a.default_deadline),
       MONTH(a.default_deadline),
       DATE_FORMAT(a.default_deadline, '%Y-%m-01'),
       LAST_DAY(a.default_deadline),
       TIMESTAMP(a.default_deadline, '17:00:00'),
       @super_id
FROM activities a
WHERE a.remarks = @demo_batch;

-- Assign each activity to 10 barangays.
INSERT INTO activity_barangays (activity_id, barangay_code)
SELECT a.activity_id, d.barangay_code
FROM activities a
JOIN demo_topic t      ON t.title = a.activity_name
JOIN demo_assignment d ON d.n = t.n
WHERE a.remarks = @demo_batch;

-- 40 submissions: slots 1-4 Confirmed, 5-6 Pending, 7-8 Denied.
-- Even slots are submitted one day late (is_late = 1, half score).
INSERT INTO submissions
  (period_id, barangay_code, submitted_by, file_name, file_path, date_submitted,
   submission_status, submission_type, is_late, score,
   confirmed_by, confirmation_date, denial_reason)
SELECT p.period_id,
       d.barangay_code,
       u.user_id,
       'Sample report.pdf',
       CONCAT('submissions/demo100-', d.n, '-', d.slot, '.pdf'),
       TIMESTAMP(IF(MOD(d.slot, 2) = 0, a.default_deadline + INTERVAL 1 DAY, a.default_deadline), '10:00:00'),
       CASE WHEN d.slot <= 4 THEN 'Confirmed' WHEN d.slot <= 6 THEN 'Pending' ELSE 'Denied' END,
       'Regular',
       MOD(d.slot, 2) = 0,
       IF(d.slot <= 4, IF(MOD(d.slot, 2) = 0, 0.5, 1), NULL),
       IF(d.slot IN (5, 6), NULL, @super_id),
       IF(d.slot IN (5, 6), NULL, TIMESTAMP(a.default_deadline + INTERVAL 2 DAY, '09:00:00')),
       IF(d.slot >= 7, 'Please attach the attendance summary.', NULL)
FROM demo_assignment d
JOIN demo_topic t         ON t.n = d.n
JOIN activities a         ON a.activity_name = t.title AND a.remarks = @demo_batch
JOIN reporting_period p   ON p.activity_id = a.activity_id
JOIN users u              ON u.barangay_code = d.barangay_code AND u.role_id = @role_brgy
WHERE d.slot <= 8
ORDER BY d.n, d.slot;

COMMIT;

DROP TEMPORARY TABLE demo_assignment, demo_slot, demo_topic;

-- Quick check of what was loaded.
SELECT (SELECT COUNT(*) FROM roles)              AS roles,
       (SELECT COUNT(*) FROM barangays)          AS barangays,
       (SELECT COUNT(*) FROM users)              AS users,
       (SELECT COUNT(*) FROM activities)         AS activities,
       (SELECT COUNT(*) FROM reporting_period)   AS reporting_periods,
       (SELECT COUNT(*) FROM activity_barangays) AS assignments,
       (SELECT COUNT(*) FROM submissions)        AS submissions;
