-- =====================================================================
-- Bantay Barangay: database schema
-- Target: MySQL 8 / MariaDB 10.5+ (InnoDB, utf8mb4)
--
-- Import order:  1) schema.sql   2) seed.sql
--
-- This file is the single source of truth for the structure. It already
-- includes everything that used to live in the add_*.sql / remove_*.sql
-- patch files (roster photo, audit log, dropped user name columns).
--
-- Not re-runnable on purpose: importing it into a database that already
-- has these tables fails instead of wiping data. To start over, drop the
-- database first.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS bantay_barangay
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bantay_barangay;


-- =====================================================================
-- 1. TABLES
-- =====================================================================

-- ---------------------------------------------------------------------
-- roles: reference data. Filled right below because the app looks roles
-- up by role_name ('Super Admin', 'Barangay Admin', 'Viewer').
-- ---------------------------------------------------------------------
CREATE TABLE roles (
  role_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  role_name     VARCHAR(30)  NOT NULL,
  description   VARCHAR(255) NULL,
  date_created  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (role_id),
  UNIQUE KEY uq_roles_name (role_name)
) ENGINE=InnoDB;

INSERT INTO roles (role_id, role_name, description) VALUES
  (1, 'Super Admin',    'DILG Talisay office. Manages activities, reviews submissions, reports and accounts.'),
  (2, 'Barangay Admin', 'Barangay account. Submits reports and manages its own roster.'),
  (3, 'Viewer',         'Public viewer. No login, read-only public pages.');

-- ---------------------------------------------------------------------
-- users <-> barangays point at each other (users.barangay_code and
-- barangays.user_id), so both are created first and the two foreign
-- keys are added once both tables exist (see section 2).
-- ---------------------------------------------------------------------
CREATE TABLE users (
  user_id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username          VARCHAR(50)  NOT NULL,
  display_name        VARCHAR(100) NULL,
  session_version     BIGINT UNSIGNED NOT NULL DEFAULT 0,
  password_hash     VARCHAR(255) NOT NULL,
  contact_number    VARCHAR(15)  NULL,
  role_id           INT UNSIGNED NOT NULL,
  barangay_code     VARCHAR(20)  NULL,           -- FK added in section 2
  account_status    VARCHAR(20)  NOT NULL DEFAULT 'Active',
  created_by        INT UNSIGNED NULL,           -- self reference
  date_created      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified     DATETIME     NULL,
  last_login        DATETIME     NULL,
  password_changed  DATETIME     NULL,
  remarks           VARCHAR(255) NULL,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_username (username),
  CONSTRAINT fk_users_role
    FOREIGN KEY (role_id) REFERENCES roles (role_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_users_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE barangays (
  barangay_code       VARCHAR(20)  NOT NULL,     -- primary key; every barangay link uses this
  barangay_name       VARCHAR(100) NOT NULL,
  municipality        VARCHAR(100) NOT NULL,
  province            VARCHAR(100) NOT NULL,
  barangay_captain    VARCHAR(100) NULL,
  barangay_secretary  VARCHAR(100) NULL,
  contact_number      VARCHAR(15)  NULL,
  email               VARCHAR(100) NULL,
  office_address      VARCHAR(255) NULL,
  user_id             INT UNSIGNED NULL,         -- the barangay's account; FK added in section 2
  status              VARCHAR(20)  NOT NULL DEFAULT 'Active',
  date_created        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified       DATETIME     NULL,
  remarks             VARCHAR(255) NULL,
  PRIMARY KEY (barangay_code),
  UNIQUE KEY uq_barangays_name (barangay_name)
) ENGINE=InnoDB;

CREATE TABLE barangay_roster (
  roster_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  barangay_code   VARCHAR(20)  NOT NULL,
  first_name      VARCHAR(50)  NOT NULL,
  middle_name     VARCHAR(50)  NULL,
  last_name       VARCHAR(50)  NOT NULL,
  suffix          VARCHAR(10)  NULL,
  position        VARCHAR(50)  NOT NULL,
  committee       VARCHAR(100) NULL,
  term_start_year SMALLINT UNSIGNED NULL,
  term_end_year   SMALLINT UNSIGNED NULL,
  contact_number  VARCHAR(15)  NULL,
  email           VARCHAR(100) NULL,
  address         VARCHAR(255) NULL,
  photo_path      VARCHAR(255) NULL,             -- relative path under App_Data/uploads
  status          VARCHAR(20)  NOT NULL DEFAULT 'Active',
  date_added      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified   DATETIME     NULL,
  date_activated  DATETIME     NULL,
  remarks         VARCHAR(255) NULL,
  PRIMARY KEY (roster_id),
  CONSTRAINT fk_roster_barangay
    FOREIGN KEY (barangay_code) REFERENCES barangays (barangay_code)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE announcements (
  announcement_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  title                 VARCHAR(150) NOT NULL,
  content               TEXT         NOT NULL,
  attachment_file_name  VARCHAR(255) NULL,
  attachment_file_path  VARCHAR(255) NULL,
  created_by            INT UNSIGNED NULL,
  date_created          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_published        DATETIME     NULL,
  expiration_date       DATETIME     NULL,
  priority              VARCHAR(20)  NULL,
  status                VARCHAR(20)  NOT NULL DEFAULT 'Draft',
  visibility_type       VARCHAR(20)  NOT NULL,
  target_role_id        INT UNSIGNED NULL,
  target_barangay_code  VARCHAR(20)  NULL,
  is_pinned             TINYINT(1)   NOT NULL DEFAULT 0,
  date_modified         DATETIME     NULL,
  remarks               VARCHAR(255) NULL,
  PRIMARY KEY (announcement_id),
  CONSTRAINT fk_announcements_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_announcements_target_role
    FOREIGN KEY (target_role_id) REFERENCES roles (role_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_announcements_target_barangay
    FOREIGN KEY (target_barangay_code) REFERENCES barangays (barangay_code)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE important_dates (
  date_id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  title                 VARCHAR(150) NOT NULL,
  description           TEXT         NULL,
  event_date            DATE         NOT NULL,
  start_time            TIME         NULL,
  end_time              TIME         NULL,
  event_type            VARCHAR(30)  NOT NULL,
  created_by            INT UNSIGNED NULL,
  date_created          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified         DATETIME     NULL,
  visibility_type       VARCHAR(20)  NOT NULL,
  target_role_id        INT UNSIGNED NULL,
  target_barangay_code  VARCHAR(20)  NULL,
  location              VARCHAR(255) NULL,
  status                VARCHAR(20)  NOT NULL DEFAULT 'Upcoming',
  reminder_date         DATETIME     NULL,
  remarks               VARCHAR(255) NULL,
  PRIMARY KEY (date_id),
  CONSTRAINT fk_important_dates_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_important_dates_target_role
    FOREIGN KEY (target_role_id) REFERENCES roles (role_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_important_dates_target_barangay
    FOREIGN KEY (target_barangay_code) REFERENCES barangays (barangay_code)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE activities (
  activity_id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  activity_name        VARCHAR(150) NOT NULL,
  description          TEXT         NULL,
  frequency            VARCHAR(30)  NOT NULL,
  instructions         TEXT         NULL,
  template_file_name   VARCHAR(255) NULL,
  template_file_type   VARCHAR(20)  NULL,
  template_link        VARCHAR(255) NULL,
  default_deadline     DATE         NULL,
  frequency_range_months SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  next_period_start    DATE         NULL,
  required_submission  TINYINT(1)   NOT NULL DEFAULT 1,
  activity_status      VARCHAR(20)  NOT NULL DEFAULT 'Active',
  is_public            TINYINT(1)   NOT NULL DEFAULT 1,
  created_by           INT UNSIGNED NULL,
  date_created         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified        DATETIME     NULL,
  date_archived        DATETIME     NULL,
  remarks              VARCHAR(255) NULL,
  PRIMARY KEY (activity_id),
  CONSTRAINT fk_activities_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Which barangays an activity is assigned to.
CREATE TABLE activity_barangays (
  activity_id    INT UNSIGNED NOT NULL,
  barangay_code  VARCHAR(20)  NOT NULL,
  PRIMARY KEY (activity_id, barangay_code),
  CONSTRAINT fk_ab_activity
    FOREIGN KEY (activity_id) REFERENCES activities (activity_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ab_barangay
    FOREIGN KEY (barangay_code) REFERENCES barangays (barangay_code)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reporting_period (
  period_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  activity_id          INT UNSIGNED NOT NULL,
  period_type          VARCHAR(30)  NOT NULL,
  period_name          VARCHAR(100) NOT NULL,
  period_year          SMALLINT UNSIGNED NOT NULL,
  period_number        TINYINT UNSIGNED  NULL,
  start_date           DATE         NOT NULL,
  end_date             DATE         NOT NULL,
  submission_deadline  DATETIME     NULL,
  grace_days           SMALLINT UNSIGNED NOT NULL DEFAULT 7,
  period_status        VARCHAR(20)  NOT NULL DEFAULT 'Open',
  date_opened          DATETIME     NULL,
  date_closed          DATETIME     NULL,
  created_by           INT UNSIGNED NULL,
  date_created         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified        DATETIME     NULL,
  remarks              VARCHAR(255) NULL,
  PRIMARY KEY (period_id),
  CONSTRAINT fk_period_activity
    FOREIGN KEY (activity_id) REFERENCES activities (activity_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_period_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- One submission per barangay per reporting period (uq_submission_period_barangay).
-- The primary key is called date_id because the app (and the ERD) use that name.
CREATE TABLE submissions (
  date_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  period_id           INT UNSIGNED NOT NULL,
  barangay_code       VARCHAR(20)  NOT NULL,
  submitted_by        INT UNSIGNED NOT NULL,     -- the barangay admin who uploaded it
  file_name           VARCHAR(255) NOT NULL,
  file_path           VARCHAR(255) NOT NULL,
  date_submitted      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  submission_status   VARCHAR(20)  NOT NULL DEFAULT 'Pending',
  submission_type     VARCHAR(30)  NULL,
  is_late             TINYINT(1)   NOT NULL DEFAULT 0,
  score               DECIMAL(5,2) NULL,
  confirmed_by        INT UNSIGNED NULL,         -- the Super Admin who reviewed it
  confirmation_date   DATETIME     NULL,
  remarks             VARCHAR(255) NULL,
  denial_reason       VARCHAR(255) NULL,
  denial_attachment   VARCHAR(255) NULL,
  resubmission_count  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  date_modified       DATETIME     NULL,
  PRIMARY KEY (date_id),
  UNIQUE KEY uq_submission_period_barangay (period_id, barangay_code),
  KEY ix_submissions_submitted_by (submitted_by),
  KEY ix_submissions_confirmed_by (confirmed_by),
  CONSTRAINT fk_submissions_period
    FOREIGN KEY (period_id) REFERENCES reporting_period (period_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_submissions_barangay
    FOREIGN KEY (barangay_code) REFERENCES barangays (barangay_code)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_submissions_submitted_by
    FOREIGN KEY (submitted_by) REFERENCES users (user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_submissions_confirmed_by
    FOREIGN KEY (confirmed_by) REFERENCES users (user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- audit_log: filled only by the triggers in section 4 (plus the app's
-- own 'Signed in' insert). performed_by_user_id is stamped from the
-- session variable @performed_by_user_id, which the app sets on every
-- write connection.
-- 'description' is a generated, human-readable sentence built from the
-- other columns.
-- ---------------------------------------------------------------------
CREATE TABLE audit_log (
  log_id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  occurred_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  performed_by_user_id  INT UNSIGNED NULL,
  barangay_code         VARCHAR(20)  NULL,
  action_name           VARCHAR(32)  NOT NULL,
  entity_name           VARCHAR(32)  NOT NULL,
  record_id             VARCHAR(32)  NOT NULL,
  details               VARCHAR(650) NOT NULL,
  description           TEXT GENERATED ALWAYS AS (
    CASE
      WHEN action_name = 'Signed in' THEN 'An account signed in successfully.'
      WHEN entity_name = 'activity_barangays' THEN
        CONCAT('Activity #', record_id,
               IF(action_name = 'Deleted', ' was removed from ', ' was assigned to '),
               barangay_code, '.')
      ELSE
        CONCAT(
          IF(action_name = 'Password changed', 'Changed the password for', action_name), ' ',
          CASE entity_name
            WHEN 'submissions'      THEN 'report'
            WHEN 'activities'       THEN 'activity'
            WHEN 'reporting_period' THEN 'reporting period'
            WHEN 'users'            THEN 'account'
            WHEN 'barangay_roster'  THEN 'roster entry'
            WHEN 'announcements'    THEN 'announcement'
            WHEN 'important_dates'  THEN 'calendar event'
            ELSE REPLACE(entity_name, '_', ' ')
          END,
          ' #', record_id, '.',
          IF(details IN ('', 'Report'), '', CONCAT(' ', details)))
    END
  ) STORED,
  PRIMARY KEY (log_id),
  KEY ix_audit_record    (entity_name, record_id, log_id),
  KEY ix_audit_time      (occurred_at),
  KEY ix_audit_barangay  (barangay_code, log_id),
  CONSTRAINT fk_audit_performed_by
    FOREIGN KEY (performed_by_user_id) REFERENCES users (user_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;


-- =====================================================================
-- 2. CIRCULAR users <-> barangays FOREIGN KEYS
-- =====================================================================

ALTER TABLE users
  ADD CONSTRAINT fk_users_barangay
    FOREIGN KEY (barangay_code) REFERENCES barangays (barangay_code)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE barangays
  ADD CONSTRAINT fk_barangays_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE;


-- =====================================================================
-- 3. VIEW
-- =====================================================================

-- Readable list of submissions: who submitted and who confirmed each one.
CREATE VIEW v_submission_details AS
SELECT s.date_id           AS submission_id,
       s.barangay_code,
       b.barangay_name,
       a.activity_name,
       p.period_name,
       s.submission_status,
       s.is_late,
       s.score,
       s.date_submitted,
       s.submitted_by,
       su.username         AS submitted_by_name,
       sr.role_name        AS submitted_by_role,
       s.confirmed_by,
       cu.username         AS confirmed_by_name,
       cr.role_name        AS confirmed_by_role,
       s.confirmation_date
FROM submissions s
JOIN barangays b         ON b.barangay_code = s.barangay_code
JOIN reporting_period p  ON p.period_id     = s.period_id
JOIN activities a        ON a.activity_id   = p.activity_id
JOIN users su            ON su.user_id      = s.submitted_by
JOIN roles sr            ON sr.role_id      = su.role_id
LEFT JOIN users cu       ON cu.user_id      = s.confirmed_by
LEFT JOIN roles cr       ON cr.role_id      = cu.role_id;


-- =====================================================================
-- 4. AUDIT TRIGGERS
-- Every trigger is a single INSERT ... SELECT, so no DELIMITER is needed
-- and the file imports cleanly in phpMyAdmin.
-- =====================================================================

-- Stamp who did it. The app sets @performed_by_user_id on its connection.
CREATE TRIGGER audit_log_performer BEFORE INSERT ON audit_log FOR EACH ROW
  SET NEW.performed_by_user_id = COALESCE(NEW.performed_by_user_id, @performed_by_user_id);

-- ---- submissions ----------------------------------------------------
CREATE TRIGGER audit_submissions_insert AFTER INSERT ON submissions FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.barangay_code, 'Submitted', 'submissions', NEW.date_id,
         CONCAT('File: ', NEW.file_name,
                '. Submitted ', IF(NEW.is_late = 1, 'late', 'on time'),
                ' for reporting period #', NEW.period_id,
                '. Status: ', NEW.submission_status, '.');

CREATE TRIGGER audit_submissions_update AFTER UPDATE ON submissions FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.barangay_code,
         CASE NEW.submission_status WHEN 'Pending' THEN 'Resubmitted' ELSE NEW.submission_status END,
         'submissions', NEW.date_id,
         CONCAT('File: ', NEW.file_name, '. ',
                IF(OLD.submission_status = NEW.submission_status,
                   CONCAT('Status: ', NEW.submission_status),
                   CONCAT('Status changed from ', OLD.submission_status, ' to ', NEW.submission_status)),
                '.',
                IFNULL(CONCAT(' Review note: ', NEW.denial_reason), ''));

CREATE TRIGGER audit_submissions_delete AFTER DELETE ON submissions FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT OLD.barangay_code, 'Deleted', 'submissions', OLD.date_id,
         CONCAT('File: ', OLD.file_name,
                '. Reporting period #', OLD.period_id,
                '. Status: ', OLD.submission_status, '.');

-- ---- activities -----------------------------------------------------
CREATE TRIGGER audit_activities_insert AFTER INSERT ON activities FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NULL, 'Created', 'activities', NEW.activity_id,
         CONCAT('Activity: ', NEW.activity_name, '.');

CREATE TRIGGER audit_activities_update AFTER UPDATE ON activities FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NULL, 'Updated', 'activities', NEW.activity_id,
         CONCAT('Activity: ', NEW.activity_name,
                IF(OLD.activity_status <> NEW.activity_status,
                   CONCAT('. Status changed from ', OLD.activity_status, ' to ', NEW.activity_status), ''),
                IF(OLD.activity_name <=> NEW.activity_name, '', '. Changed activity name'),
                IF(OLD.frequency <=> NEW.frequency,
                   '', CONCAT('. Frequency changed from ', OLD.frequency, ' to ', NEW.frequency)),
                IF(OLD.instructions <=> NEW.instructions, '', '. Changed instructions'),
                IF(OLD.default_deadline <=> NEW.default_deadline, '', '. Changed default deadline'),
                IF(OLD.is_public <=> NEW.is_public, '', '. Changed is public'),
                IF(OLD.description <=> NEW.description, '', '. Changed description'),
                '.');

CREATE TRIGGER audit_activities_delete AFTER DELETE ON activities FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NULL, 'Deleted', 'activities', OLD.activity_id,
         CONCAT('Activity: ', OLD.activity_name, '.');

-- ---- reporting_period -----------------------------------------------
CREATE TRIGGER audit_reporting_period_insert AFTER INSERT ON reporting_period FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NULL, 'Created', 'reporting_period', NEW.period_id,
         CONCAT('Period: ', NEW.period_name, '.');

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

CREATE TRIGGER audit_reporting_period_delete AFTER DELETE ON reporting_period FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NULL, 'Deleted', 'reporting_period', OLD.period_id,
         CONCAT('Period: ', OLD.period_name, '.');

-- ---- users ----------------------------------------------------------
CREATE TRIGGER audit_users_insert AFTER INSERT ON users FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.barangay_code, 'Created', 'users', NEW.user_id,
         CONCAT('Username: ', NEW.username, '.');

-- Only logs when something audit-worthy changed (last_login alone is ignored).
CREATE TRIGGER audit_users_update AFTER UPDATE ON users FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.barangay_code,
         CASE WHEN OLD.password_hash <> NEW.password_hash THEN 'Password changed' ELSE 'Updated' END,
         'users', NEW.user_id,
         CONCAT('Username: ', NEW.username,
                IF(OLD.account_status <> NEW.account_status,
                   CONCAT('. Status changed from ', OLD.account_status, ' to ', NEW.account_status), ''),
                IF(OLD.username <=> NEW.username, '', '. Changed username'),
                IF(OLD.contact_number <=> NEW.contact_number, '', '. Changed contact number'),
                IF(OLD.role_id <=> NEW.role_id, '', '. Changed role id'),
                IF(OLD.barangay_code <=> NEW.barangay_code, '', '. Changed barangay code'),
                '.')
  WHERE NOT (OLD.password_hash   <=> NEW.password_hash
         AND OLD.account_status  <=> NEW.account_status
         AND OLD.username        <=> NEW.username
         AND OLD.contact_number  <=> NEW.contact_number
         AND OLD.role_id         <=> NEW.role_id
         AND OLD.barangay_code   <=> NEW.barangay_code);

CREATE TRIGGER audit_users_delete AFTER DELETE ON users FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT OLD.barangay_code, 'Deleted', 'users', OLD.user_id,
         CONCAT('Username: ', OLD.username, '.');

-- ---- barangay_roster ------------------------------------------------
CREATE TRIGGER audit_barangay_roster_insert AFTER INSERT ON barangay_roster FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.barangay_code, 'Created', 'barangay_roster', NEW.roster_id,
         CONCAT('Position: ', NEW.position, '.');

CREATE TRIGGER audit_barangay_roster_update AFTER UPDATE ON barangay_roster FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.barangay_code, 'Updated', 'barangay_roster', NEW.roster_id,
         CONCAT('Position: ', NEW.position,
                IF(OLD.status <> NEW.status,
                   CONCAT('. Status changed from ', OLD.status, ' to ', NEW.status), ''),
                IF(OLD.position <=> NEW.position, '', '. Changed position'),
                IF(OLD.first_name <=> NEW.first_name, '', '. Changed first name'),
                IF(OLD.last_name <=> NEW.last_name, '', '. Changed last name'),
                IF(OLD.committee <=> NEW.committee, '', '. Changed committee'),
                IF(OLD.contact_number <=> NEW.contact_number, '', '. Changed contact number'),
                IF(OLD.email <=> NEW.email, '', '. Changed email'),
                IF(OLD.photo_path <=> NEW.photo_path, '', '. Changed photo path'),
                '.');

CREATE TRIGGER audit_barangay_roster_delete AFTER DELETE ON barangay_roster FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT OLD.barangay_code, 'Deleted', 'barangay_roster', OLD.roster_id,
         CONCAT('Position: ', OLD.position, '.');

-- ---- announcements --------------------------------------------------
CREATE TRIGGER audit_announcements_insert AFTER INSERT ON announcements FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.target_barangay_code, 'Created', 'announcements', NEW.announcement_id,
         CONCAT('Title: ', NEW.title, '.');

CREATE TRIGGER audit_announcements_update AFTER UPDATE ON announcements FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.target_barangay_code, 'Updated', 'announcements', NEW.announcement_id,
         CONCAT('Title: ', NEW.title,
                IF(OLD.status <> NEW.status,
                   CONCAT('. Status changed from ', OLD.status, ' to ', NEW.status), ''),
                IF(OLD.title <=> NEW.title, '', '. Changed title'),
                IF(OLD.content <=> NEW.content, '', '. Changed content'),
                IF(OLD.expiration_date <=> NEW.expiration_date, '', '. Changed expiration date'),
                IF(OLD.priority <=> NEW.priority, '', '. Changed priority'),
                IF(OLD.visibility_type <=> NEW.visibility_type, '', '. Changed visibility type'),
                IF(OLD.target_barangay_code <=> NEW.target_barangay_code, '', '. Changed target barangay code'),
                IF(OLD.is_pinned <=> NEW.is_pinned, '', '. Changed is pinned'),
                '.');

CREATE TRIGGER audit_announcements_delete AFTER DELETE ON announcements FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT OLD.target_barangay_code, 'Deleted', 'announcements', OLD.announcement_id,
         CONCAT('Title: ', OLD.title, '.');

-- ---- important_dates ------------------------------------------------
CREATE TRIGGER audit_important_dates_insert AFTER INSERT ON important_dates FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.target_barangay_code, 'Created', 'important_dates', NEW.date_id,
         CONCAT('Event: ', NEW.title, '.');

CREATE TRIGGER audit_important_dates_update AFTER UPDATE ON important_dates FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.target_barangay_code, 'Updated', 'important_dates', NEW.date_id,
         CONCAT('Event: ', NEW.title,
                IF(OLD.status <> NEW.status,
                   CONCAT('. Status changed from ', OLD.status, ' to ', NEW.status), ''),
                IF(OLD.title <=> NEW.title, '', '. Changed title'),
                IF(OLD.event_date <=> NEW.event_date, '', '. Changed event date'),
                IF(OLD.start_time <=> NEW.start_time, '', '. Changed start time'),
                IF(OLD.end_time <=> NEW.end_time, '', '. Changed end time'),
                IF(OLD.location <=> NEW.location, '', '. Changed location'),
                IF(OLD.reminder_date <=> NEW.reminder_date, '', '. Changed reminder date'),
                IF(OLD.visibility_type <=> NEW.visibility_type, '', '. Changed visibility type'),
                IF(OLD.target_barangay_code <=> NEW.target_barangay_code, '', '. Changed target barangay code'),
                '.');

CREATE TRIGGER audit_important_dates_delete AFTER DELETE ON important_dates FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT OLD.target_barangay_code, 'Deleted', 'important_dates', OLD.date_id,
         CONCAT('Event: ', OLD.title, '.');

-- ---- activity_barangays ---------------------------------------------
CREATE TRIGGER audit_activity_barangays_insert AFTER INSERT ON activity_barangays FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT NEW.barangay_code, 'Assigned', 'activity_barangays', NEW.activity_id, 'Activity assignment';

CREATE TRIGGER audit_activity_barangays_delete AFTER DELETE ON activity_barangays FOR EACH ROW
  INSERT INTO audit_log (barangay_code, action_name, entity_name, record_id, details)
  SELECT OLD.barangay_code, 'Deleted', 'activity_barangays', OLD.activity_id, 'Activity assignment';
