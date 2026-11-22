-- Select the current Bantay Barangay database before running this upgrade.
SET @roster_start_sql = IF(EXISTS (
  SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE()
    AND table_name = 'barangay_roster' AND column_name = 'term_start_year'
), 'DO 0', 'ALTER TABLE barangay_roster ADD COLUMN term_start_year SMALLINT UNSIGNED NULL AFTER committee');
PREPARE roster_upgrade FROM @roster_start_sql;
EXECUTE roster_upgrade;
DEALLOCATE PREPARE roster_upgrade;

SET @roster_end_sql = IF(EXISTS (
  SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE()
    AND table_name = 'barangay_roster' AND column_name = 'term_end_year'
), 'DO 0', 'ALTER TABLE barangay_roster ADD COLUMN term_end_year SMALLINT UNSIGNED NULL AFTER term_start_year');
PREPARE roster_upgrade FROM @roster_end_sql;
EXECUTE roster_upgrade;
DEALLOCATE PREPARE roster_upgrade;
