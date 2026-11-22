-- Run on the database selected by the Stable site's BantayDb setting.
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS display_name VARCHAR(100) NULL AFTER username,
    ADD COLUMN IF NOT EXISTS session_version BIGINT UNSIGNED NOT NULL DEFAULT 0 AFTER display_name;

CREATE OR REPLACE TRIGGER audit_reporting_period_update AFTER UPDATE ON reporting_period FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NULL, 'Updated', 'reporting_period', NEW.period_id,
         CONCAT('Period: ', NEW.period_name,
                IF(OLD.period_status <> NEW.period_status,
                   CONCAT('. Status changed from ', OLD.period_status, ' to ', NEW.period_status), ''),
                IF(OLD.period_name <=> NEW.period_name, '', '. Changed period name'),
                IF(OLD.submission_deadline <=> NEW.submission_deadline, '',
                   CONCAT('. Deadline: ', OLD.submission_deadline, ' to ', NEW.submission_deadline)),
                IF(OLD.start_date <=> NEW.start_date, '', '. Changed start date'),
                IF(OLD.end_date <=> NEW.end_date, '', '. Changed end date'),
                '.');

-- Close legacy archived periods. Submission records and uploaded evidence are retained.
UPDATE reporting_period p
JOIN activities a ON a.activity_id = p.activity_id
SET p.period_status = 'Closed',
    p.date_closed = COALESCE(p.date_closed, a.date_archived, NOW())
WHERE a.activity_status = 'Archived' AND p.period_status <> 'Closed';
