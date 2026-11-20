-- Copy data from the original schema into a NEW bantay_barangay_v2 database.
-- Create the destination from the new schema first. Do not seed the destination.
-- Stop the application and back up the original database and App_Data/uploads first.
-- No statements modify tables in the original bantay_barangay database.

USE bantay_barangay_v2;
DELIMITER $$
CREATE PROCEDURE bantay_copy_legacy_data()
SQL SECURITY INVOKER
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
  START TRANSACTION WITH CONSISTENT SNAPSHOT;

  IF EXISTS (SELECT 1 FROM barangays)
     OR EXISTS (SELECT 1 FROM users)
     OR EXISTS (SELECT 1 FROM barangay_roster)
     OR EXISTS (SELECT 1 FROM announcements)
     OR EXISTS (SELECT 1 FROM important_dates)
     OR EXISTS (SELECT 1 FROM activities)
     OR EXISTS (SELECT 1 FROM reporting_period)
     OR EXISTS (SELECT 1 FROM activity_barangays)
     OR EXISTS (SELECT 1 FROM submissions) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination already contains data. Use an empty v2 database without seed.sql.';
  END IF;

  IF EXISTS (SELECT 1 FROM bantay_barangay.submissions WHERE submitted_by IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A legacy submission has no submitter. Resolve its ownership before upgrading.';
  END IF;

  IF EXISTS (SELECT 1 FROM bantay_barangay.users u LEFT JOIN roles r ON r.role_name = u.role WHERE r.role_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A legacy user has a role missing from the new roles table.';
  END IF;

  IF EXISTS (SELECT 1 FROM bantay_barangay.announcements t LEFT JOIN roles r ON r.role_name = t.target_role WHERE t.target_role IS NOT NULL AND r.role_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A legacy announcements record targets an unknown role.';
  END IF;

  IF EXISTS (SELECT 1 FROM bantay_barangay.important_dates t LEFT JOIN roles r ON r.role_name = t.target_role WHERE t.target_role IS NOT NULL AND r.role_id IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A legacy important_dates record targets an unknown role.';
  END IF;

  INSERT INTO barangays (
    barangay_code, barangay_name, municipality, province, barangay_captain,
    barangay_secretary, contact_number, email, office_address, user_id,
    status, date_created, date_modified, remarks
  )
  SELECT
    t.barangay_code, t.barangay_name, t.municipality, t.province, t.barangay_captain,
    t.barangay_secretary, t.contact_number, t.email, t.office_address, NULL,
    t.status, t.date_created, t.date_modified, t.remarks
  FROM bantay_barangay.barangays t;

  INSERT INTO users (
    user_id, username, password_hash, first_name, middle_name,
    last_name, suffix, contact_number, role_id, barangay_code,
    account_status, created_by, date_created, date_modified, last_login,
    password_changed, remarks
  )
  SELECT
    t.user_id, t.username, t.password_hash, t.first_name, t.middle_name,
    t.last_name, t.suffix, t.contact_number, r.role_id, b.barangay_code,
    t.account_status, NULL, t.date_created, t.date_modified, t.last_login,
    t.password_changed, t.remarks
  FROM bantay_barangay.users t
  LEFT JOIN bantay_barangay.barangays b ON b.barangay_id = t.barangay_id
  LEFT JOIN roles r ON r.role_name = t.role;

  -- Restore circular and self-references once both parent tables are populated.
  UPDATE users u JOIN bantay_barangay.users old ON old.user_id = u.user_id
    SET u.created_by = old.created_by;

  UPDATE barangays b JOIN bantay_barangay.barangays old ON old.barangay_code = b.barangay_code
    SET b.user_id = old.user_id;

  INSERT INTO barangay_roster (
    roster_id, barangay_code, first_name, middle_name, last_name,
    suffix, position, committee, contact_number, email,
    address, status, date_added, date_modified, date_activated,
    remarks
  )
  SELECT
    t.roster_id, b.barangay_code, t.first_name, t.middle_name, t.last_name,
    t.suffix, t.position, t.committee, t.contact_number, t.email,
    t.address, t.status, t.date_added, t.date_modified, t.date_activated,
    t.remarks
  FROM bantay_barangay.barangay_roster t
  LEFT JOIN bantay_barangay.barangays b ON b.barangay_id = t.barangay_id;

  INSERT INTO announcements (
    announcement_id, title, content, attachment_file_name, attachment_file_path,
    created_by, date_created, date_published, expiration_date, priority,
    status, visibility_type, target_role_id, target_barangay_code, is_pinned,
    date_modified, remarks
  )
  SELECT
    t.announcement_id, t.title, t.content, t.attachment_file_name, t.attachment_file_path,
    t.created_by, t.date_created, t.date_published, t.expiration_date, t.priority,
    t.status, t.visibility_type, r.role_id, b.barangay_code, t.is_pinned,
    t.date_modified, t.remarks
  FROM bantay_barangay.announcements t
  LEFT JOIN bantay_barangay.barangays b ON b.barangay_id = t.target_barangay_id
  LEFT JOIN roles r ON r.role_name = t.target_role;

  INSERT INTO important_dates (
    date_id, title, description, event_date, start_time,
    end_time, event_type, created_by, date_created, date_modified,
    visibility_type, target_role_id, target_barangay_code, location, status,
    reminder_date, remarks
  )
  SELECT
    t.date_id, t.title, t.description, t.event_date, t.start_time,
    t.end_time, t.event_type, t.created_by, t.date_created, t.date_modified,
    t.visibility_type, r.role_id, b.barangay_code, t.location, t.status,
    t.reminder_date, t.remarks
  FROM bantay_barangay.important_dates t
  LEFT JOIN bantay_barangay.barangays b ON b.barangay_id = t.target_barangay_id
  LEFT JOIN roles r ON r.role_name = t.target_role;

  INSERT INTO activities (
    activity_id, activity_name, description, frequency, instructions,
    template_file_name, template_file_type, template_link, default_deadline, required_submission,
    activity_status, is_public, created_by, date_created, date_modified,
    date_archived, remarks
  )
  SELECT
    t.activity_id, t.activity_name, t.description, t.frequency, t.instructions,
    t.template_file_name, t.template_file_type, t.template_link, t.default_deadline, t.required_submission,
    t.activity_status, t.is_public, t.created_by, t.date_created, t.date_modified,
    t.date_archived, t.remarks
  FROM bantay_barangay.activities t;

  INSERT INTO reporting_period (
    period_id, activity_id, period_type, period_name, period_year,
    period_number, start_date, end_date, submission_deadline, period_status,
    date_opened, date_closed, created_by, date_created, date_modified,
    remarks
  )
  SELECT
    t.period_id, t.activity_id, t.period_type, t.period_name, t.period_year,
    t.period_number, t.start_date, t.end_date, t.submission_deadline, t.period_status,
    t.date_opened, t.date_closed, t.created_by, t.date_created, t.date_modified,
    t.remarks
  FROM bantay_barangay.reporting_period t;

  INSERT INTO activity_barangays (
    activity_id, barangay_code
  )
  SELECT
    t.activity_id, b.barangay_code
  FROM bantay_barangay.activity_barangays t
  LEFT JOIN bantay_barangay.barangays b ON b.barangay_id = t.barangay_id;

  INSERT INTO submissions (
    date_id, period_id, barangay_code, submitted_by, file_name,
    file_path, date_submitted, submission_status, submission_type, is_late,
    score, confirmed_by, confirmation_date, remarks, denial_reason,
    denial_attachment, resubmission_count, date_modified
  )
  SELECT
    t.date_id, t.period_id, b.barangay_code, t.submitted_by, t.file_name,
    t.file_path, t.date_submitted, t.submission_status, t.submission_type, t.is_late,
    t.score, t.confirmed_by, t.confirmation_date, t.remarks, t.denial_reason,
    t.denial_attachment, t.resubmission_count, t.date_modified
  FROM bantay_barangay.submissions t
  LEFT JOIN bantay_barangay.barangays b ON b.barangay_id = t.barangay_id;

  IF (SELECT COUNT(*) FROM barangays) <> (SELECT COUNT(*) FROM bantay_barangay.barangays) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in barangays. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM users) <> (SELECT COUNT(*) FROM bantay_barangay.users) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in users. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM barangay_roster) <> (SELECT COUNT(*) FROM bantay_barangay.barangay_roster) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in barangay_roster. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM announcements) <> (SELECT COUNT(*) FROM bantay_barangay.announcements) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in announcements. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM important_dates) <> (SELECT COUNT(*) FROM bantay_barangay.important_dates) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in important_dates. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM activities) <> (SELECT COUNT(*) FROM bantay_barangay.activities) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in activities. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM reporting_period) <> (SELECT COUNT(*) FROM bantay_barangay.reporting_period) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in reporting_period. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM activity_barangays) <> (SELECT COUNT(*) FROM bantay_barangay.activity_barangays) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in activity_barangays. Changes rolled back.';
  END IF;

  IF (SELECT COUNT(*) FROM submissions) <> (SELECT COUNT(*) FROM bantay_barangay.submissions) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Row count mismatch in submissions. Changes rolled back.';
  END IF;

  COMMIT;
END$$
DELIMITER ;

CALL bantay_copy_legacy_data();
DROP PROCEDURE bantay_copy_legacy_data;
