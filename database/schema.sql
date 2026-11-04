-- Bantay Barangay schema (ERD + group-approved additions: activity_barangays table, activities.is_public)
-- Target: MySQL 8 / MariaDB. Column names, PKs and FKs follow the diagram.
-- The diagram has no data types, so the types below are sensible assumptions.

CREATE DATABASE IF NOT EXISTS bantay_barangay
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bantay_barangay;

-- ---------------------------------------------------------------
-- USERS and BARANGAYS reference each other (USERS.barangay_id and
-- BARANGAYS.user_id), so both are created first and their
-- cross FKs are added at the bottom with ALTER TABLE.
-- ---------------------------------------------------------------

CREATE TABLE users (
  user_id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username          VARCHAR(50)  NOT NULL,
  password_hash     VARCHAR(255) NOT NULL,
  first_name        VARCHAR(50)  NOT NULL,
  middle_name       VARCHAR(50)  NULL,
  last_name         VARCHAR(50)  NOT NULL,
  suffix            VARCHAR(10)  NULL,
  contact_number    VARCHAR(15)  NULL,
  role              VARCHAR(30)  NOT NULL,
  barangay_id       INT UNSIGNED NULL,          -- FK added below
  account_status    VARCHAR(20)  NOT NULL DEFAULT 'Active',
  created_by        INT UNSIGNED NULL,          -- self reference
  date_created      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified     DATETIME     NULL,
  last_login        DATETIME     NULL,
  password_changed  DATETIME     NULL,
  remarks           VARCHAR(255) NULL,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_username (username),
  CONSTRAINT fk_users_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE barangays (
  barangay_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  barangay_name       VARCHAR(100) NOT NULL,
  barangay_code       VARCHAR(20)  NOT NULL,
  municipality        VARCHAR(100) NOT NULL,
  province            VARCHAR(100) NOT NULL,
  barangay_captain    VARCHAR(100) NULL,
  barangay_secretary  VARCHAR(100) NULL,
  contact_number      VARCHAR(15)  NULL,
  email               VARCHAR(100) NULL,
  office_address      VARCHAR(255) NULL,
  user_id             INT UNSIGNED NULL,        -- FK added below
  status              VARCHAR(20)  NOT NULL DEFAULT 'Active',
  date_created        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified       DATETIME     NULL,
  remarks             VARCHAR(255) NULL,
  PRIMARY KEY (barangay_id),
  UNIQUE KEY uq_barangays_code (barangay_code)
) ENGINE=InnoDB;

CREATE TABLE barangay_roster (
  roster_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  barangay_id     INT UNSIGNED NOT NULL,
  first_name      VARCHAR(50)  NOT NULL,
  middle_name     VARCHAR(50)  NULL,
  last_name       VARCHAR(50)  NOT NULL,
  suffix          VARCHAR(10)  NULL,
  position        VARCHAR(50)  NOT NULL,
  committee       VARCHAR(100) NULL,            -- "commitee" in the diagram
  contact_number  VARCHAR(15)  NULL,
  email           VARCHAR(100) NULL,
  address         VARCHAR(255) NULL,
  status          VARCHAR(20)  NOT NULL DEFAULT 'Active',
  date_added      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified   DATETIME     NULL,
  date_activated  DATETIME     NULL,
  remarks         VARCHAR(255) NULL,
  PRIMARY KEY (roster_id),
  CONSTRAINT fk_roster_barangay
    FOREIGN KEY (barangay_id) REFERENCES barangays (barangay_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE announcements (                    -- "ANOUNCEMENTS" in the diagram
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
  target_role           VARCHAR(30)  NULL,
  target_barangay_id    INT UNSIGNED NULL,
  is_pinned             TINYINT(1)   NOT NULL DEFAULT 0,
  date_modified         DATETIME     NULL,
  remarks               VARCHAR(255) NULL,
  PRIMARY KEY (announcement_id),
  CONSTRAINT fk_announcements_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_announcements_target_barangay
    FOREIGN KEY (target_barangay_id) REFERENCES barangays (barangay_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE important_dates (
  date_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  title               VARCHAR(150) NOT NULL,
  description         TEXT         NULL,
  event_date          DATE         NOT NULL,
  start_time          TIME         NULL,
  end_time            TIME         NULL,
  event_type          VARCHAR(30)  NOT NULL,
  created_by          INT UNSIGNED NULL,
  date_created        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified       DATETIME     NULL,
  visibility_type     VARCHAR(20)  NOT NULL,
  target_role         VARCHAR(30)  NULL,
  target_barangay_id  INT UNSIGNED NULL,
  location            VARCHAR(255) NULL,
  status              VARCHAR(20)  NOT NULL DEFAULT 'Upcoming',
  reminder_date       DATETIME     NULL,
  remarks             VARCHAR(255) NULL,
  PRIMARY KEY (date_id),
  CONSTRAINT fk_important_dates_created_by
    FOREIGN KEY (created_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_important_dates_target_barangay
    FOREIGN KEY (target_barangay_id) REFERENCES barangays (barangay_id)
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

CREATE TABLE reporting_period (
  period_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  activity_id          INT UNSIGNED NOT NULL,
  period_type          VARCHAR(30)  NOT NULL,
  period_name          VARCHAR(100) NOT NULL,
  period_year          SMALLINT UNSIGNED NOT NULL,
  period_number        TINYINT UNSIGNED  NULL,
  start_date           DATE         NOT NULL,
  end_date             DATE         NOT NULL,
  submission_deadline  DATETIME     NOT NULL,
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

CREATE TABLE submissions (
  date_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,  -- PK name as drawn in the diagram
  period_id           INT UNSIGNED NOT NULL,
  barangay_id         INT UNSIGNED NOT NULL,
  submitted_by        INT UNSIGNED NULL,
  file_name           VARCHAR(255) NOT NULL,
  file_path           VARCHAR(255) NOT NULL,
  date_submitted      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  submission_status   VARCHAR(20)  NOT NULL DEFAULT 'Pending',
  submission_type     VARCHAR(30)  NULL,
  is_late             TINYINT(1)   NOT NULL DEFAULT 0,
  score               DECIMAL(5,2) NULL,
  confirmed_by        INT UNSIGNED NULL,
  confirmation_date   DATETIME     NULL,           -- "confiramtion_date" in the diagram
  remarks             VARCHAR(255) NULL,
  denial_reason       VARCHAR(255) NULL,
  denial_attachment   VARCHAR(255) NULL,
  resubmission_count  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  date_modified       DATETIME     NULL,
  PRIMARY KEY (date_id),
  UNIQUE KEY uq_submission_period_barangay (period_id, barangay_id),
  CONSTRAINT fk_submissions_period
    FOREIGN KEY (period_id) REFERENCES reporting_period (period_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_submissions_barangay
    FOREIGN KEY (barangay_id) REFERENCES barangays (barangay_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_submissions_submitted_by
    FOREIGN KEY (submitted_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_submissions_confirmed_by
    FOREIGN KEY (confirmed_by) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- Circular USERS <-> BARANGAYS foreign keys
-- ---------------------------------------------------------------
ALTER TABLE users
  ADD CONSTRAINT fk_users_barangay
    FOREIGN KEY (barangay_id) REFERENCES barangays (barangay_id)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE barangays
  ADD CONSTRAINT fk_barangays_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- ---------------------------------------------------------------
-- Group-approved addition: which barangays an activity is assigned to
-- ---------------------------------------------------------------
CREATE TABLE activity_barangays (
  activity_id  INT UNSIGNED NOT NULL,
  barangay_id  INT UNSIGNED NOT NULL,
  PRIMARY KEY (activity_id, barangay_id),
  CONSTRAINT fk_ab_activity
    FOREIGN KEY (activity_id) REFERENCES activities (activity_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ab_barangay
    FOREIGN KEY (barangay_id) REFERENCES barangays (barangay_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
