-- Run on the existing database selected in the app's BantayDb setting.
SET @period_upgrade = IF(EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE()
  AND table_name = 'activities' AND column_name = 'frequency_range_months'), 'DO 0',
  'ALTER TABLE activities ADD COLUMN frequency_range_months SMALLINT UNSIGNED NOT NULL DEFAULT 0');
PREPARE period_upgrade FROM @period_upgrade;
EXECUTE period_upgrade;
DEALLOCATE PREPARE period_upgrade;

SET @period_upgrade = IF(EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE()
  AND table_name = 'activities' AND column_name = 'next_period_start'), 'DO 0',
  'ALTER TABLE activities ADD COLUMN next_period_start DATE NULL');
PREPARE period_upgrade FROM @period_upgrade;
EXECUTE period_upgrade;
DEALLOCATE PREPARE period_upgrade;

SET @period_upgrade = IF(EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE()
  AND table_name = 'reporting_period' AND column_name = 'grace_days'), 'DO 0',
  'ALTER TABLE reporting_period ADD COLUMN grace_days SMALLINT UNSIGNED NOT NULL DEFAULT 7');
PREPARE period_upgrade FROM @period_upgrade;
EXECUTE period_upgrade;
DEALLOCATE PREPARE period_upgrade;

ALTER TABLE reporting_period MODIFY COLUMN submission_deadline DATETIME NULL;

DROP TRIGGER IF EXISTS audit_reporting_period_update;
CREATE TRIGGER audit_reporting_period_update AFTER UPDATE ON reporting_period FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NULL, 'Updated', 'reporting_period', NEW.period_id,
         CONCAT('Period: ', NEW.period_name,
                IF(OLD.period_status <> NEW.period_status,
                   CONCAT('. Status changed from ', OLD.period_status, ' to ', NEW.period_status), ''),
                IF(OLD.period_name <=> NEW.period_name, '', '. Changed period name'),
                IF(OLD.submission_deadline <=> NEW.submission_deadline, '',
                   CONCAT('. Deadline: ', COALESCE(CAST(OLD.submission_deadline AS CHAR), 'Not set'),
                          ' to ', COALESCE(CAST(NEW.submission_deadline AS CHAR), 'Not set'))),
                IF(OLD.grace_days = NEW.grace_days, '', CONCAT('. Grace days: ', OLD.grace_days, ' to ', NEW.grace_days)),
                IF(OLD.start_date <=> NEW.start_date, '', '. Changed start date'),
                IF(OLD.end_date <=> NEW.end_date, '', '. Changed end date'),
                '.');
