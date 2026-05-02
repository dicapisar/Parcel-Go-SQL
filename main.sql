-- ─────────────────────────────────────────────────────
-- PARCELGO – MySQL Database Schema
-- ─────────────────────────────────────────────────────

-- ══ DATABASE CREATION ════════════════════════════════

CREATE DATABASE IF NOT EXISTS parcelgo
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE parcelgo;

-- ══ AUDIT & LOGS ════════════════════════════════════

CREATE TABLE `audit_records` (
  `audit_id`    INT PRIMARY KEY AUTO_INCREMENT,
  `action`      ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  `table_name`  VARCHAR(50) NOT NULL,
  `record_id`   INT NOT NULL,
  `changed_at`  DATETIME NOT NULL,
  `user_type`   ENUM('staff','customer','driver','system') NOT NULL,
  `user_id`     INT NOT NULL,
  `before_data` JSON NULL,
  `after_data`  JSON NULL
);

CREATE TABLE `notification_logs` (
  `notification_log_id` INT PRIMARY KEY AUTO_INCREMENT,
  `notification_id`     INT NOT NULL COMMENT 'soft ref to notifications',
  `attempted_at`        DATETIME NOT NULL,
  `channel_type_id`     INT NOT NULL COMMENT 'soft ref to channel_types',
  `status`              ENUM('sent','failed') NOT NULL,
  `failure_reason`      VARCHAR(255)
);

CREATE TABLE `pay_attempt_logs` (
  `attempt_id`     INT PRIMARY KEY AUTO_INCREMENT,
  `invoice_id`     INT NOT NULL COMMENT 'soft ref to invoices',
  `attempted_at`   DATETIME NOT NULL,
  `method_id`      INT NOT NULL COMMENT 'soft ref to payment_methods',
  `amount`         DECIMAL(10,2) NOT NULL,
  `status`         ENUM('success','failed','declined') NOT NULL,
  `failure_reason` VARCHAR(255)
);

CREATE TABLE `scan_alert_logs` (
  `scan_alert_id` INT PRIMARY KEY AUTO_INCREMENT,
  `parcel_id`     INT NOT NULL COMMENT 'soft ref to parcels',
  `depot_id`      INT NOT NULL COMMENT 'soft ref to depots',
  `alert_type`    VARCHAR(50) NOT NULL,
  `raised_at`     DATETIME NOT NULL,
  `resolved_at`   DATETIME,
  `resolved_by`   INT COMMENT 'soft ref to staff',
  `comments`      TEXT
);

-- ══ SUSTAINABILITY ═══════════════════════════════════

CREATE TABLE `emission_records` (
  `emission_record_id` INT PRIMARY KEY AUTO_INCREMENT,
  `emission_amount`    DECIMAL(10,4) NOT NULL,
  `baseline`           DECIMAL(10,4),
  `emissions_saved`    DECIMAL(10,4),
  `assignment_id`      INT NOT NULL
);

CREATE TABLE `sustainability_reports` (
  `gp_account_id`   INT NOT NULL,
  `report_id`       INT NOT NULL,
  `start_date`      DATE NOT NULL,
  `end_date`        DATE NOT NULL,
  `total_emissions` DECIMAL(10,4),
  `total_saved`     DECIMAL(10,4),
  `eco_option_usage` VARCHAR(100),
  PRIMARY KEY (`gp_account_id`, `report_id`)
);

CREATE TABLE `gp_accounts` (
  `gp_account_id` INT PRIMARY KEY AUTO_INCREMENT,
  `gp_balance`    DECIMAL(10,2) DEFAULT 0,
  `customer_id`   INT NOT NULL
);

CREATE TABLE `gp_transactions` (
  `transaction_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `transaction_at`   DATETIME NOT NULL,
  `transaction_type` ENUM('earned','redeemed','expired') NOT NULL,
  `gp_amount`        DECIMAL(10,2) NOT NULL,
  `expiry_date`      DATE,
  `emission_record_id` INT NOT NULL,
  `gp_account_id`    INT NOT NULL
);

-- ══ COMMUNICATIONS ═══════════════════════════════════

CREATE TABLE `chat_sessions` (
  `chat_session_id` INT PRIMARY KEY AUTO_INCREMENT,
  `session_id`      INT NOT NULL,
  `started_at`      DATETIME NOT NULL,
  `last_chat_at`    DATETIME,
  `status`          ENUM('open','closed','archived') NOT NULL,
  `staff_id`        INT NOT NULL,
  `customer_id`     INT NOT NULL
);

CREATE TABLE `chat_messages` (
  `chat_session_id` INT NOT NULL,
  `chat_message_id` INT NOT NULL,
  `sender`          VARCHAR(20) NOT NULL,
  `sent_at`         DATETIME NOT NULL,
  `content`         TEXT NOT NULL,
  `is_received`     BOOLEAN DEFAULT false,
  PRIMARY KEY (`chat_session_id`, `chat_message_id`)
);

CREATE TABLE `certifications` (
  `certification_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `certification_num`  VARCHAR(50) NOT NULL,
  `certification_name` VARCHAR(100) NOT NULL,
  `issued_on`          DATE NOT NULL,
  `valid_until`        DATE NOT NULL,
  `driver_id`          INT NOT NULL
);

CREATE TABLE `notifications` (
  `notification_id`  INT PRIMARY KEY AUTO_INCREMENT,
  `channel_type_id`  INT NOT NULL,
  `content`          TEXT,
  `sent_at`          DATETIME,
  `delivery_status`  ENUM('sent','failed','pending') NOT NULL,
  `tracking_event_id` INT,
  `customer_id`      INT NOT NULL
);

-- ══ USERS ════════════════════════════════════════════

CREATE TABLE `customers` (
  `customer_id`       INT PRIMARY KEY AUTO_INCREMENT,
  `first_name`        VARCHAR(50) NOT NULL,
  `last_name`         VARCHAR(50) NOT NULL,
  `dob`               DATE,
  `account_status`    ENUM('active','suspended','closed') NOT NULL,
  `credentials_id`    INT,
  `billing_details_id` INT
);

CREATE TABLE `credentials` (
  `credentials_id`      INT PRIMARY KEY AUTO_INCREMENT,
  `user_name`           VARCHAR(100) UNIQUE NOT NULL,
  `password`            VARCHAR(255) NOT NULL,
  `mfa`                 BOOLEAN DEFAULT false,
  `last_login`          DATETIME,
  `last_password_change` DATETIME
);

CREATE TABLE `staff` (
  `staff_id`            INT PRIMARY KEY AUTO_INCREMENT,
  `first_name`          VARCHAR(50) NOT NULL,
  `last_name`           VARCHAR(50) NOT NULL,
  `mobile_phone`        VARCHAR(20),
  `work_phone`          VARCHAR(20),
  `email`               VARCHAR(100) UNIQUE NOT NULL,
  `manager_id`          INT,
  `role_id`             INT NOT NULL,
  `staff_credentials_id` INT
);

CREATE TABLE `staff_credentials` (
  `staff_credentials_id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_name`            VARCHAR(100) UNIQUE NOT NULL,
  `password`             VARCHAR(255) NOT NULL,
  `mfa`                  BOOLEAN DEFAULT false,
  `last_login`           DATETIME,
  `last_password_change` DATETIME
);

CREATE TABLE `roles` (
  `role_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `role_name` VARCHAR(50) NOT NULL
);

CREATE TABLE `drivers` (
  `driver_id`            INT PRIMARY KEY AUTO_INCREMENT,
  `first_name`           VARCHAR(50) NOT NULL,
  `last_name`            VARCHAR(50) NOT NULL,
  `mobile_phone`         VARCHAR(20),
  `email`                VARCHAR(100) UNIQUE NOT NULL,
  `staff_credentials_id` INT
);

CREATE TABLE `licenses` (
  `license_id`     INT PRIMARY KEY AUTO_INCREMENT,
  `license_num`    VARCHAR(50) NOT NULL,
  `license_type`   VARCHAR(50) NOT NULL,
  `issued_on`      DATE NOT NULL,
  `state_of_issue` VARCHAR(50),
  `valid_until`    DATE NOT NULL,
  `driver_id`      INT NOT NULL
);

CREATE TABLE `contact_details` (
  `contact_detail_id`    INT PRIMARY KEY AUTO_INCREMENT,
  `contact_value`        VARCHAR(100) NOT NULL,
  `contact_info`         VARCHAR(100),
  `use_for_notification` BOOLEAN DEFAULT false,
  `channel_type_id`      INT NOT NULL,
  `customer_id`          INT NOT NULL
);

CREATE TABLE `channel_types` (
  `channel_type_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `channel_type_name` VARCHAR(50) NOT NULL,
  `format`            VARCHAR(50)
);

-- ══ LOCATION ═════════════════════════════════════════

CREATE TABLE `countries` (
  `country_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `name`         VARCHAR(100) NOT NULL,
  `country_code` VARCHAR(10) NOT NULL
);

CREATE TABLE `states` (
  `state_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `name`       VARCHAR(50) NOT NULL,
  `state_code` VARCHAR(10),
  `country_id` INT NOT NULL
);

CREATE TABLE `cities` (
  `city_id`    INT PRIMARY KEY AUTO_INCREMENT,
  `name`       VARCHAR(50) NOT NULL,
  `state_id`   INT,
  `country_id` INT NOT NULL
);

CREATE TABLE `postal_codes` (
  `postal_code_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name`           VARCHAR(50) NOT NULL,
  `city_id`        INT NOT NULL
);

CREATE TABLE `suburbs` (
  `suburb_id`      INT PRIMARY KEY AUTO_INCREMENT,
  `name`           VARCHAR(100) NOT NULL,
  `postal_code_id` INT NOT NULL
);

CREATE TABLE `addresses` (
  `address_id`     INT PRIMARY KEY AUTO_INCREMENT,
  `unit`           VARCHAR(20),
  `number`         VARCHAR(20) NOT NULL,
  `street_1`       VARCHAR(100) NOT NULL,
  `street_2`       VARCHAR(100),
  `notes`          TEXT,
  `suburb_id`      INT,
  `postal_code_id` INT NOT NULL
);

CREATE TABLE `customer_addresses` (
  `customer_id` INT NOT NULL,
  `address_id`  INT NOT NULL,
  `label`       VARCHAR(50),
  `is_default`  BOOLEAN DEFAULT false,
  PRIMARY KEY (`customer_id`, `address_id`)
);

CREATE TABLE `depots` (
  `depot_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `depot_name` VARCHAR(100) NOT NULL,
  `notes`      TEXT,
  `phone`      VARCHAR(20),
  `email`      VARCHAR(100),
  `address_id` INT NOT NULL
);

CREATE TABLE `storage_slots` (
  `depot_id`        INT NOT NULL,
  `storage_slot_id` INT NOT NULL,
  `zone`            VARCHAR(20),
  `aisle`           VARCHAR(20),
  `bay`             VARCHAR(20),
  `shelf`           VARCHAR(20),
  `status`          VARCHAR(20) NOT NULL,
  PRIMARY KEY (`depot_id`, `storage_slot_id`)
);

-- ══ FLEET ════════════════════════════════════════════

CREATE TABLE `vehicle_types` (
  `vehicle_type_id`  INT PRIMARY KEY AUTO_INCREMENT,
  `type_name`        VARCHAR(50) NOT NULL,
  `license_required` VARCHAR(50)
);

CREATE TABLE `vehicles` (
  `vehicle_id`      INT PRIMARY KEY AUTO_INCREMENT,
  `registration`    VARCHAR(20) UNIQUE NOT NULL,
  `capacity`        DECIMAL(8,2),
  `is_available`    BOOLEAN DEFAULT true,
  `vehicle_type_id` INT NOT NULL
);

CREATE TABLE `vehicle_maintenances` (
  `v_maintenance_id`  INT PRIMARY KEY AUTO_INCREMENT,
  `maintenance_date`  DATE NOT NULL,
  `maintenance_type`  ENUM('routine','repair','inspection') NOT NULL,
  `notes`             TEXT,
  `status`            ENUM('scheduled','in_progress','completed') NOT NULL,
  `vehicle_id`        INT NOT NULL,
  `recorded_by`       INT
);

CREATE TABLE `routes` (
  `route_id`       INT PRIMARY KEY AUTO_INCREMENT,
  `route_name`     VARCHAR(100),
  `origin`         INT NOT NULL,
  `destination`    INT NOT NULL,
  `distance`       DECIMAL(8,2),
  `duration_estim` DECIMAL(5,2),
  `service_type`   ENUM('standard','express','eco') NOT NULL,
  `route_type`     ENUM('pickup','inter-depot','delivery') NOT NULL
);

CREATE TABLE `assignments` (
  `assignment_id` INT PRIMARY KEY AUTO_INCREMENT,
  `created_at`    DATETIME NOT NULL,
  `start_at`      DATETIME,
  `end_at`        DATETIME,
  `status`        ENUM('scheduled','in_progress','completed','cancelled') NOT NULL,
  `route_id`      INT NOT NULL,
  `vehicle_id`    INT NOT NULL,
  `driver_id`     INT NOT NULL
);

CREATE TABLE `assignment_parcels` (
  `assignment_id` INT NOT NULL,
  `parcel_id`     INT NOT NULL,
  `created_at`    DATETIME NOT NULL,
  `created_by`    INT,
  PRIMARY KEY (`assignment_id`, `parcel_id`)
);

-- ══ PARCELS & ORDERS ═════════════════════════════════

CREATE TABLE `lifecycle_status` (
  `status_id`   INT PRIMARY KEY AUTO_INCREMENT,
  `name`        VARCHAR(50) NOT NULL,
  `description` TEXT
);

CREATE TABLE `event_types` (
  `event_type_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name`          VARCHAR(50) NOT NULL,
  `description`   TEXT
);

CREATE TABLE `parcel_categories` (
  `category_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name`        VARCHAR(50) NOT NULL,
  `description` TEXT
);

CREATE TABLE `parcels` (
  `parcel_id`           INT PRIMARY KEY AUTO_INCREMENT,
  `weight`              DECIMAL(8,2),
  `height`              DECIMAL(8,2),
  `width`               DECIMAL(8,2),
  `length`              DECIMAL(8,2),
  `notes`               TEXT,
  `lifecycle_status_id` INT NOT NULL,
  `parcel_category_id`  INT,
  `pickup_add_id`       INT,
  `delivery_add_id`     INT,
  `order_id`            INT NOT NULL
);

CREATE TABLE `tracking_events` (
  `tracking_event_id` INT PRIMARY KEY AUTO_INCREMENT,
  `created_at`        DATETIME NOT NULL,
  `notes`             TEXT,
  `event_type_id`     INT NOT NULL,
  `assignment_id`     INT,
  `parcel_id`         INT NOT NULL,
  `address_id`        INT,
  `staff_id`          INT
);

CREATE TABLE `parcel_slot_assignments` (
  `parcel_id`         INT NOT NULL,
  `slot_assignment_id` INT NOT NULL,
  `check_in_at`       DATETIME,
  `check_out_at`      DATETIME,
  `handling_status`   ENUM('checked_in','in_storage','checked_out','flagged') NOT NULL,
  `alert_flag`        BOOLEAN DEFAULT false,
  `depot_id`          INT NOT NULL,
  `storage_slot_id`   INT NOT NULL,
  PRIMARY KEY (`parcel_id`, `slot_assignment_id`)
);

CREATE TABLE `orders` (
  `order_id`      INT PRIMARY KEY AUTO_INCREMENT,
  `total_weight`  DECIMAL(8,2),
  `placed_at`     DATETIME NOT NULL,
  `status`        ENUM('draft','confirmed','in_transit','delivered','cancelled') NOT NULL,
  `notes`         TEXT,
  `customer_id`   INT NOT NULL
);

-- ══ BILLING & PRICING ════════════════════════════════

CREATE TABLE `billing_details` (
  `billing_detail_id` INT PRIMARY KEY AUTO_INCREMENT,
  `billing_name`      VARCHAR(100) NOT NULL,
  `notes`             TEXT,
  `customer_id`       INT NOT NULL,
  `address_id`        INT NOT NULL,
  `payment_method_id` INT
);

CREATE TABLE `payment_methods` (
  `payment_method_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name`              VARCHAR(50) NOT NULL,
  `description`       TEXT,
  `fee`               DECIMAL(5,2) DEFAULT 0
);

CREATE TABLE `payments` (
  `payment_id`        INT PRIMARY KEY AUTO_INCREMENT,
  `transaction_ref`   VARCHAR(100),
  `transaction_at`    DATETIME NOT NULL,
  `amount`            DECIMAL(10,2) NOT NULL,
  `currency`          VARCHAR(3) NOT NULL,
  `status`            ENUM('pending','completed','failed') NOT NULL,
  `failure_reason`    VARCHAR(255),
  `payment_method_id` INT NOT NULL,
  `invoice_id`        INT NOT NULL
);

CREATE TABLE `refunds` (
  `payment_id`        INT NOT NULL,
  `refund_id`         INT NOT NULL,
  `refunded_at`       DATETIME NOT NULL,
  `amount`            DECIMAL(10,2) NOT NULL,
  `reason`            TEXT,
  `status`            ENUM('pending','processed','rejected') NOT NULL,
  `payment_method_id` INT NOT NULL,
  PRIMARY KEY (`payment_id`, `refund_id`)
);

CREATE TABLE `discount_rules` (
  `discount_rule_id`    INT PRIMARY KEY AUTO_INCREMENT,
  `customer_segment`    VARCHAR(50),
  `threshold`           DECIMAL(10,2),
  `discount_percentage` DECIMAL(5,2) NOT NULL
);

CREATE TABLE `rates` (
  `rate_id`             INT PRIMARY KEY AUTO_INCREMENT,
  `delivery_zone`       VARCHAR(50) NOT NULL,
  `weight_band`         DECIMAL(8,2) NOT NULL,
  `service_level`       ENUM('standard','express','eco') NOT NULL,
  `eco_delivery_option` BOOLEAN DEFAULT false,
  `base_price`          DECIMAL(10,2) NOT NULL
);

CREATE TABLE `invoices` (
  `invoice_id`       INT PRIMARY KEY AUTO_INCREMENT,
  `billing_period`   VARCHAR(50),
  `invoiced_at`      DATETIME NOT NULL,
  `status`           ENUM('draft','issued','paid','overdue','cancelled') NOT NULL,
  `total_amount`     DECIMAL(10,2) NOT NULL,
  `currency`         VARCHAR(10) NOT NULL,
  `billing_detail_id` INT NOT NULL,
  `discount_rule_id` INT
);

CREATE TABLE `invoice_lines` (
  `invoice_id`       INT NOT NULL,
  `line_id`          INT NOT NULL,
  `description`      TEXT,
  `quantity`         INT NOT NULL,
  `unit_price`       DECIMAL(10,2) NOT NULL,
  `line_amount`      DECIMAL(10,2) NOT NULL,
  `discount_rule_id` INT,
  `rate_id`          INT NOT NULL,
  `parcel_id`        INT NOT NULL,
  PRIMARY KEY (`invoice_id`, `line_id`)
);

-- ══ FOREIGN KEYS ═════════════════════════════════════

ALTER TABLE `emission_records` ADD FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`);

ALTER TABLE `sustainability_reports` ADD FOREIGN KEY (`gp_account_id`) REFERENCES `gp_accounts` (`gp_account_id`);

ALTER TABLE `gp_accounts` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

ALTER TABLE `gp_transactions` ADD FOREIGN KEY (`emission_record_id`) REFERENCES `emission_records` (`emission_record_id`);

ALTER TABLE `gp_transactions` ADD FOREIGN KEY (`gp_account_id`) REFERENCES `gp_accounts` (`gp_account_id`);

ALTER TABLE `chat_sessions` ADD FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`);

ALTER TABLE `chat_sessions` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

ALTER TABLE `chat_messages` ADD FOREIGN KEY (`chat_session_id`) REFERENCES `chat_sessions` (`chat_session_id`);

ALTER TABLE `certifications` ADD FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`);

ALTER TABLE `notifications` ADD FOREIGN KEY (`channel_type_id`) REFERENCES `channel_types` (`channel_type_id`);

ALTER TABLE `notifications` ADD FOREIGN KEY (`tracking_event_id`) REFERENCES `tracking_events` (`tracking_event_id`);

ALTER TABLE `notifications` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

ALTER TABLE `customers` ADD FOREIGN KEY (`credentials_id`) REFERENCES `credentials` (`credentials_id`);

ALTER TABLE `customers` ADD FOREIGN KEY (`billing_details_id`) REFERENCES `billing_details` (`billing_detail_id`);

ALTER TABLE `staff` ADD FOREIGN KEY (`manager_id`) REFERENCES `staff` (`staff_id`);

ALTER TABLE `staff` ADD FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);

ALTER TABLE `staff` ADD FOREIGN KEY (`staff_credentials_id`) REFERENCES `staff_credentials` (`staff_credentials_id`);

ALTER TABLE `drivers` ADD FOREIGN KEY (`staff_credentials_id`) REFERENCES `staff_credentials` (`staff_credentials_id`);

ALTER TABLE `licenses` ADD FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`);

ALTER TABLE `contact_details` ADD FOREIGN KEY (`channel_type_id`) REFERENCES `channel_types` (`channel_type_id`);

ALTER TABLE `contact_details` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

ALTER TABLE `states` ADD FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`);

ALTER TABLE `cities` ADD FOREIGN KEY (`state_id`) REFERENCES `states` (`state_id`);

ALTER TABLE `cities` ADD FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`);

ALTER TABLE `postal_codes` ADD FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`);

ALTER TABLE `suburbs` ADD FOREIGN KEY (`postal_code_id`) REFERENCES `postal_codes` (`postal_code_id`);

ALTER TABLE `addresses` ADD FOREIGN KEY (`suburb_id`) REFERENCES `suburbs` (`suburb_id`);

ALTER TABLE `addresses` ADD FOREIGN KEY (`postal_code_id`) REFERENCES `postal_codes` (`postal_code_id`);

ALTER TABLE `customer_addresses` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

ALTER TABLE `customer_addresses` ADD FOREIGN KEY (`address_id`) REFERENCES `addresses` (`address_id`);

ALTER TABLE `depots` ADD FOREIGN KEY (`address_id`) REFERENCES `addresses` (`address_id`);

ALTER TABLE `storage_slots` ADD FOREIGN KEY (`depot_id`) REFERENCES `depots` (`depot_id`);

ALTER TABLE `vehicles` ADD FOREIGN KEY (`vehicle_type_id`) REFERENCES `vehicle_types` (`vehicle_type_id`);

ALTER TABLE `vehicle_maintenances` ADD FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`);

ALTER TABLE `vehicle_maintenances` ADD FOREIGN KEY (`recorded_by`) REFERENCES `staff` (`staff_id`);

ALTER TABLE `routes` ADD FOREIGN KEY (`origin`) REFERENCES `addresses` (`address_id`);

ALTER TABLE `routes` ADD FOREIGN KEY (`destination`) REFERENCES `addresses` (`address_id`);

ALTER TABLE `assignments` ADD FOREIGN KEY (`route_id`) REFERENCES `routes` (`route_id`);

ALTER TABLE `assignments` ADD FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`vehicle_id`);

ALTER TABLE `assignments` ADD FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`);

ALTER TABLE `assignment_parcels` ADD FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`);

ALTER TABLE `assignment_parcels` ADD FOREIGN KEY (`parcel_id`) REFERENCES `parcels` (`parcel_id`);

ALTER TABLE `assignment_parcels` ADD FOREIGN KEY (`created_by`) REFERENCES `staff` (`staff_id`);

ALTER TABLE `parcels` ADD FOREIGN KEY (`lifecycle_status_id`) REFERENCES `lifecycle_status` (`status_id`);

ALTER TABLE `parcels` ADD FOREIGN KEY (`parcel_category_id`) REFERENCES `parcel_categories` (`category_id`);

ALTER TABLE `parcels` ADD FOREIGN KEY (`pickup_add_id`) REFERENCES `addresses` (`address_id`);

ALTER TABLE `parcels` ADD FOREIGN KEY (`delivery_add_id`) REFERENCES `addresses` (`address_id`);

ALTER TABLE `parcels` ADD FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);

ALTER TABLE `tracking_events` ADD FOREIGN KEY (`event_type_id`) REFERENCES `event_types` (`event_type_id`);

ALTER TABLE `tracking_events` ADD FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`);

ALTER TABLE `tracking_events` ADD FOREIGN KEY (`parcel_id`) REFERENCES `parcels` (`parcel_id`);

ALTER TABLE `tracking_events` ADD FOREIGN KEY (`address_id`) REFERENCES `addresses` (`address_id`);

ALTER TABLE `tracking_events` ADD FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`);

ALTER TABLE `parcel_slot_assignments` ADD FOREIGN KEY (`parcel_id`) REFERENCES `parcels` (`parcel_id`);

ALTER TABLE `parcel_slot_assignments` ADD FOREIGN KEY (`depot_id`, `storage_slot_id`) REFERENCES `storage_slots` (`depot_id`, `storage_slot_id`);

ALTER TABLE `orders` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

ALTER TABLE `billing_details` ADD FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`payment_method_id`);

ALTER TABLE `billing_details` ADD FOREIGN KEY (`customer_id`, `address_id`) REFERENCES `customer_addresses` (`customer_id`, `address_id`);

ALTER TABLE `payments` ADD FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`payment_method_id`);

ALTER TABLE `payments` ADD FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`);

ALTER TABLE `refunds` ADD FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`);

ALTER TABLE `refunds` ADD FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`payment_method_id`);

ALTER TABLE `invoices` ADD FOREIGN KEY (`billing_detail_id`) REFERENCES `billing_details` (`billing_detail_id`);

ALTER TABLE `invoices` ADD FOREIGN KEY (`discount_rule_id`) REFERENCES `discount_rules` (`discount_rule_id`);

ALTER TABLE `invoice_lines` ADD FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`);

ALTER TABLE `invoice_lines` ADD FOREIGN KEY (`discount_rule_id`) REFERENCES `discount_rules` (`discount_rule_id`);

ALTER TABLE `invoice_lines` ADD FOREIGN KEY (`rate_id`) REFERENCES `rates` (`rate_id`);

ALTER TABLE `invoice_lines` ADD FOREIGN KEY (`parcel_id`) REFERENCES `parcels` (`parcel_id`);


-- ═════════════════════════════════════════════════════════════════
-- PARCELGO – Audit & Log Trigger Logic
-- ═════════════════════════════════════════════════════════════════
-- This file implements three layers of trigger logic:
--
-- LAYER 1 – SOFT REFERENCE VALIDATION
--   Applies to: notification_logs, pay_attempt_logs
--   These log tables intentionally have no hard FK constraints,
--   so that historical log records are preserved even if parent
--   records are later deleted. BEFORE INSERT triggers enforce
--   referential integrity at insert time without FK constraints.
--
-- LAYER 2 – AUTO-LOG (CAMERA) TRIGGERS
--   Applies to: notifications → notification_logs
--               payments     → pay_attempt_logs
--   These triggers fire after a row is inserted into a core table
--   and automatically write a corresponding entry into the matching
--   log table. No manual insert into the log table is needed.
--
-- LAYER 3 – AUDIT TRAIL
--   Applies to: customers, orders, parcels, invoices, payments,
--               staff, drivers, vehicles
--   AFTER INSERT / UPDATE / DELETE triggers write one row to
--   audit_records on every data change, capturing the action,
--   table name, affected record ID, and timestamp.
--
--   Note: user_id defaults to 0 and user_type to 'system' because
--   MySQL triggers do not have native session-user context. In a
--   production app, set session variables before each operation:
--     SET @current_user_id   = 42;
--     SET @current_user_type = 'staff';
--   and reference them inside the trigger body.
-- ═════════════════════════════════════════════════════════════════

USE parcelgo;

DELIMITER //

-- ═════════════════════════════════════════════════════════════════
-- LAYER 1 — SOFT REFERENCE VALIDATION TRIGGERS
-- ═════════════════════════════════════════════════════════════════

-- ── notification_logs ─────────────────────────────────────────────
-- Validates that notification_id exists in notifications
-- and channel_type_id exists in channel_types before any insert.

CREATE TRIGGER trg_notification_logs_before_insert
BEFORE INSERT ON notification_logs
FOR EACH ROW
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM notifications
    WHERE notification_id = NEW.notification_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'notification_logs: notification_id does not exist in notifications';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM channel_types
    WHERE channel_type_id = NEW.channel_type_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'notification_logs: channel_type_id does not exist in channel_types';
  END IF;
END;
//

-- ── pay_attempt_logs ──────────────────────────────────────────────
-- Validates that invoice_id exists in invoices
-- and method_id exists in payment_methods before any insert.

CREATE TRIGGER trg_pay_attempt_logs_before_insert
BEFORE INSERT ON pay_attempt_logs
FOR EACH ROW
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM invoices
    WHERE invoice_id = NEW.invoice_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'pay_attempt_logs: invoice_id does not exist in invoices';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM payment_methods
    WHERE payment_method_id = NEW.method_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'pay_attempt_logs: method_id does not exist in payment_methods';
  END IF;
END;
//

-- ═════════════════════════════════════════════════════════════════
-- LAYER 2 — AUTO-LOG (CAMERA) TRIGGERS
-- ═════════════════════════════════════════════════════════════════

-- ── notifications → notification_logs ────────────────────────────
-- Fires after every insert into notifications.
-- Automatically creates a matching row in notification_logs,
-- recording the channel, delivery status, and attempt timestamp.
-- The Layer 1 validation trigger will also fire on this insert.

CREATE TRIGGER trg_notifications_log
AFTER INSERT ON notifications
FOR EACH ROW
BEGIN
  INSERT INTO notification_logs (
    notification_id,
    attempted_at,
    channel_type_id,
    status,
    failure_reason
  )
  VALUES (
    NEW.notification_id,
    NOW(),
    NEW.channel_type_id,
    CASE NEW.delivery_status
      WHEN 'sent'   THEN 'sent'
      WHEN 'failed' THEN 'failed'
      ELSE 'failed'
    END,
    NULL
  );
END;
//

-- ── payments → pay_attempt_logs ───────────────────────────────────
-- Fires before every insert into payments.
-- Automatically creates a matching row in pay_attempt_logs,
-- recording the invoice, method, amount, and outcome status.
-- The Layer 1 validation trigger will also fire on this insert.

CREATE TRIGGER trg_payments_log
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
  INSERT INTO pay_attempt_logs (
    invoice_id,
    attempted_at,
    method_id,
    amount,
    status,
    failure_reason
  )
  VALUES (
    NEW.invoice_id,
    NOW(),
    NEW.payment_method_id,
    NEW.amount,
    CASE NEW.status
      WHEN 'completed' THEN 'success'
      WHEN 'failed'    THEN 'failed'
      ELSE 'declined'
    END,
    NEW.failure_reason
  );
END;
//

-- ═════════════════════════════════════════════════════════════════
-- LAYER 3 — AUDIT TRAIL TRIGGERS
-- ═════════════════════════════════════════════════════════════════
-- INSERT → after_data captures the new row, before_data is NULL
-- UPDATE → before_data captures old values, after_data captures new
-- DELETE → before_data captures the deleted row, after_data is NULL
-- ═════════════════════════════════════════════════════════════════

-- ── customers ─────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_customers_insert
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'customers', NEW.customer_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name,
                'dob', NEW.dob, 'account_status', NEW.account_status)
  );
END;
//

CREATE TRIGGER trg_audit_customers_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'customers', NEW.customer_id, NOW(), 'system', 0,
    JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name,
                'dob', OLD.dob, 'account_status', OLD.account_status),
    JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name,
                'dob', NEW.dob, 'account_status', NEW.account_status)
  );
END;
//

CREATE TRIGGER trg_audit_customers_delete
AFTER DELETE ON customers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'customers', OLD.customer_id, NOW(), 'system', 0,
    JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name,
                'dob', OLD.dob, 'account_status', OLD.account_status),
    NULL
  );
END;
//

-- ── orders ────────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_orders_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'orders', NEW.order_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('customer_id', NEW.customer_id, 'status', NEW.status,
                'placed_at', NEW.placed_at, 'total_weight', NEW.total_weight)
  );
END;
//

CREATE TRIGGER trg_audit_orders_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'orders', NEW.order_id, NOW(), 'system', 0,
    JSON_OBJECT('customer_id', OLD.customer_id, 'status', OLD.status,
                'placed_at', OLD.placed_at, 'total_weight', OLD.total_weight),
    JSON_OBJECT('customer_id', NEW.customer_id, 'status', NEW.status,
                'placed_at', NEW.placed_at, 'total_weight', NEW.total_weight)
  );
END;
//

CREATE TRIGGER trg_audit_orders_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'orders', OLD.order_id, NOW(), 'system', 0,
    JSON_OBJECT('customer_id', OLD.customer_id, 'status', OLD.status,
                'placed_at', OLD.placed_at, 'total_weight', OLD.total_weight),
    NULL
  );
END;
//

-- ── parcels ───────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_parcels_insert
AFTER INSERT ON parcels
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'parcels', NEW.parcel_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('order_id', NEW.order_id, 'lifecycle_status_id', NEW.lifecycle_status_id,
                'weight', NEW.weight, 'parcel_category_id', NEW.parcel_category_id)
  );
END;
//

CREATE TRIGGER trg_audit_parcels_update
AFTER UPDATE ON parcels
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'parcels', NEW.parcel_id, NOW(), 'system', 0,
    JSON_OBJECT('order_id', OLD.order_id, 'lifecycle_status_id', OLD.lifecycle_status_id,
                'weight', OLD.weight, 'parcel_category_id', OLD.parcel_category_id),
    JSON_OBJECT('order_id', NEW.order_id, 'lifecycle_status_id', NEW.lifecycle_status_id,
                'weight', NEW.weight, 'parcel_category_id', NEW.parcel_category_id)
  );
END;
//

CREATE TRIGGER trg_audit_parcels_delete
AFTER DELETE ON parcels
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'parcels', OLD.parcel_id, NOW(), 'system', 0,
    JSON_OBJECT('order_id', OLD.order_id, 'lifecycle_status_id', OLD.lifecycle_status_id,
                'weight', OLD.weight, 'parcel_category_id', OLD.parcel_category_id),
    NULL
  );
END;
//

-- ── invoices ──────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_invoices_insert
AFTER INSERT ON invoices
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'invoices', NEW.invoice_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('billing_detail_id', NEW.billing_detail_id, 'total_amount', NEW.total_amount,
                'status', NEW.status, 'invoiced_at', NEW.invoiced_at)
  );
END;
//

CREATE TRIGGER trg_audit_invoices_update
AFTER UPDATE ON invoices
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'invoices', NEW.invoice_id, NOW(), 'system', 0,
    JSON_OBJECT('billing_detail_id', OLD.billing_detail_id, 'total_amount', OLD.total_amount,
                'status', OLD.status, 'invoiced_at', OLD.invoiced_at),
    JSON_OBJECT('billing_detail_id', NEW.billing_detail_id, 'total_amount', NEW.total_amount,
                'status', NEW.status, 'invoiced_at', NEW.invoiced_at)
  );
END;
//

CREATE TRIGGER trg_audit_invoices_delete
AFTER DELETE ON invoices
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'invoices', OLD.invoice_id, NOW(), 'system', 0,
    JSON_OBJECT('billing_detail_id', OLD.billing_detail_id, 'total_amount', OLD.total_amount,
                'status', OLD.status, 'invoiced_at', OLD.invoiced_at),
    NULL
  );
END;
//

-- ── payments ──────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_payments_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'payments', NEW.payment_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('invoice_id', NEW.invoice_id, 'amount', NEW.amount,
                'status', NEW.status, 'payment_method_id', NEW.payment_method_id)
  );
END;
//

CREATE TRIGGER trg_audit_payments_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'payments', NEW.payment_id, NOW(), 'system', 0,
    JSON_OBJECT('invoice_id', OLD.invoice_id, 'amount', OLD.amount,
                'status', OLD.status, 'payment_method_id', OLD.payment_method_id),
    JSON_OBJECT('invoice_id', NEW.invoice_id, 'amount', NEW.amount,
                'status', NEW.status, 'payment_method_id', NEW.payment_method_id)
  );
END;
//

CREATE TRIGGER trg_audit_payments_delete
AFTER DELETE ON payments
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'payments', OLD.payment_id, NOW(), 'system', 0,
    JSON_OBJECT('invoice_id', OLD.invoice_id, 'amount', OLD.amount,
                'status', OLD.status, 'payment_method_id', OLD.payment_method_id),
    NULL
  );
END;
//

-- ── staff ─────────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_staff_insert
AFTER INSERT ON staff
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'staff', NEW.staff_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name,
                'email', NEW.email, 'role_id', NEW.role_id)
  );
END;
//

CREATE TRIGGER trg_audit_staff_update
AFTER UPDATE ON staff
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'staff', NEW.staff_id, NOW(), 'system', 0,
    JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name,
                'email', OLD.email, 'role_id', OLD.role_id),
    JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name,
                'email', NEW.email, 'role_id', NEW.role_id)
  );
END;
//

CREATE TRIGGER trg_audit_staff_delete
AFTER DELETE ON staff
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'staff', OLD.staff_id, NOW(), 'system', 0,
    JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name,
                'email', OLD.email, 'role_id', OLD.role_id),
    NULL
  );
END;
//

-- ── drivers ───────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_drivers_insert
AFTER INSERT ON drivers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'drivers', NEW.driver_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name,
                'email', NEW.email, 'mobile_phone', NEW.mobile_phone)
  );
END;
//

CREATE TRIGGER trg_audit_drivers_update
AFTER UPDATE ON drivers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'drivers', NEW.driver_id, NOW(), 'system', 0,
    JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name,
                'email', OLD.email, 'mobile_phone', OLD.mobile_phone),
    JSON_OBJECT('first_name', NEW.first_name, 'last_name', NEW.last_name,
                'email', NEW.email, 'mobile_phone', NEW.mobile_phone)
  );
END;
//

CREATE TRIGGER trg_audit_drivers_delete
AFTER DELETE ON drivers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'drivers', OLD.driver_id, NOW(), 'system', 0,
    JSON_OBJECT('first_name', OLD.first_name, 'last_name', OLD.last_name,
                'email', OLD.email, 'mobile_phone', OLD.mobile_phone),
    NULL
  );
END;
//

-- ── vehicles ──────────────────────────────────────────────────────

CREATE TRIGGER trg_audit_vehicles_insert
AFTER INSERT ON vehicles
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('INSERT', 'vehicles', NEW.vehicle_id, NOW(), 'system', 0,
    NULL,
    JSON_OBJECT('registration', NEW.registration, 'vehicle_type_id', NEW.vehicle_type_id,
                'capacity', NEW.capacity, 'is_available', NEW.is_available)
  );
END;
//

CREATE TRIGGER trg_audit_vehicles_update
AFTER UPDATE ON vehicles
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('UPDATE', 'vehicles', NEW.vehicle_id, NOW(), 'system', 0,
    JSON_OBJECT('registration', OLD.registration, 'vehicle_type_id', OLD.vehicle_type_id,
                'capacity', OLD.capacity, 'is_available', OLD.is_available),
    JSON_OBJECT('registration', NEW.registration, 'vehicle_type_id', NEW.vehicle_type_id,
                'capacity', NEW.capacity, 'is_available', NEW.is_available)
  );
END;
//

CREATE TRIGGER trg_audit_vehicles_delete
AFTER DELETE ON vehicles
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id, before_data, after_data)
  VALUES ('DELETE', 'vehicles', OLD.vehicle_id, NOW(), 'system', 0,
    JSON_OBJECT('registration', OLD.registration, 'vehicle_type_id', OLD.vehicle_type_id,
                'capacity', OLD.capacity, 'is_available', OLD.is_available),
    NULL
  );
END;
//

DELIMITER ;


-- ─────────────────────────────────────────────────────
-- PARCELGO – Expanded Sample Data
-- Coherent story: ~40 customers, ~100 orders, ~150 parcels
-- Includes foundational data + generated volume for testing.
-- ─────────────────────────────────────────────────────

USE parcelgo;

-- ══ LOOKUP TABLES ════════════════════════════════════

INSERT INTO roles (role_id, role_name) VALUES
    (1, 'Operations Administrator'),
    (2, 'Billing Administrator'),
    (3, 'Warehouse Staff'),
    (4, 'Support Agent'),
    (5, 'Manager'),
    (6, 'Driver');

INSERT INTO channel_types (channel_type_id, channel_type_name, format) VALUES
    (1, 'Email',  'text/html'),
    (2, 'SMS',    'text/plain'),
    (3, 'WhatsApp', 'text/plain');

INSERT INTO lifecycle_status (status_id, name, description) VALUES
    (1,  'Draft',           'Order created but not yet submitted'),
    (2,  'Booked',          'Order confirmed and booked'),
    (3,  'Picked Up',       'Parcel collected from sender'),
    (4,  'Depot Handling',  'Parcel at depot being sorted'),
    (5,  'Out for Delivery','Parcel on final delivery run'),
    (6,  'Delivered',       'Parcel successfully delivered'),
    (7,  'Cancelled',       'Order cancelled by customer or system'),
    (8,  'Returned',        'Parcel returned to sender'),
    (9,  'Refunded',        'Refund issued for this parcel');

INSERT INTO event_types (event_type_id, name, description) VALUES
    (1, 'Picked Up',        'Parcel collected from sender address'),
    (2, 'Depot Arrival',    'Parcel arrived at depot'),
    (3, 'In Storage',       'Parcel assigned to storage slot'),
    (4, 'Dispatched',       'Parcel dispatched for delivery'),
    (5, 'Delivered',        'Parcel delivered to recipient'),
    (6, 'Delivery Failed',  'Delivery attempt failed'),
    (7, 'Returned',         'Parcel returned to depot'),
    (8, 'Cancelled',        'Parcel cancelled');

INSERT INTO parcel_categories (category_id, name, description) VALUES
    (1, 'Standard',   'General goods, no special handling'),
    (2, 'Fragile',    'Fragile items requiring careful handling'),
    (3, 'Perishable', 'Temperature-sensitive items'),
    (4, 'Oversized',  'Items exceeding standard size limits'),
    (5, 'Document',   'Envelopes and document packages');

INSERT INTO payment_methods (payment_method_id, name, description, fee) VALUES
    (1, 'Credit Card', 'Visa or Mastercard',        1.50),
    (2, 'PayPal',      'PayPal payment',             2.00),
    (3, 'Direct Debit','Bank direct debit',          0.00),
    (4, 'Debit Card',  'Visa Debit or Mastercard Debit', 0.50);

INSERT INTO discount_rules (discount_rule_id, customer_segment, threshold, discount_percentage) VALUES
    (1, 'bulk',     5,    5.00),
    (2, 'bulk',     10,   10.00),
    (3, 'frequent', NULL, 7.50),
    (4, 'promo',    NULL, 15.00);

INSERT INTO rates (rate_id, delivery_zone, weight_band, service_level, eco_delivery_option, base_price) VALUES
    (1,  'Metro',        2.00,  'standard', false, 8.50),
    (2,  'Metro',        5.00,  'standard', false, 12.00),
    (3,  'Metro',        10.00, 'standard', false, 18.00),
    (4,  'Metro',        2.00,  'express',  false, 14.00),
    (5,  'Metro',        5.00,  'express',  false, 20.00),
    (6,  'Regional',     2.00,  'standard', false, 11.00),
    (7,  'Regional',     5.00,  'standard', false, 16.00),
    (8,  'Regional',     10.00, 'standard', false, 24.00),
    (9,  'Regional',     2.00,  'express',  false, 18.00),
    (10, 'Inter-State',  5.00,  'standard', false, 22.00),
    (11, 'Inter-State',  10.00, 'standard', false, 32.00),
    (12, 'Inter-State',  5.00,  'express',  false, 38.00),
    (13, 'Metro',        2.00,  'eco',      true,  7.00),
    (14, 'Regional',     5.00,  'eco',      true,  13.00);

-- ══ LOCATION ═════════════════════════════════════════

INSERT INTO countries (country_id, name, country_code) VALUES
    (1, 'Australia', 'AU');

INSERT INTO states (state_id, name, state_code, country_id) VALUES
    (1, 'New South Wales',   'NSW', 1),
    (2, 'Victoria',          'VIC', 1),
    (3, 'Queensland',        'QLD', 1),
    (4, 'South Australia',   'SA',  1),
    (5, 'Western Australia', 'WA',  1);

INSERT INTO cities (city_id, name, state_id, country_id) VALUES
    (1, 'Sydney',     1, 1),
    (2, 'Melbourne',  2, 1),
    (3, 'Brisbane',   3, 1),
    (4, 'Adelaide',   4, 1),
    (5, 'Perth',      5, 1);

INSERT INTO postal_codes (postal_code_id, name, city_id) VALUES
    (1,  '2000', 1), (2,  '2010', 1), (3,  '2060', 1),
    (4,  '3000', 2), (5,  '3004', 2), (6,  '4000', 3),
    (7,  '4101', 3), (8,  '5000', 4), (9,  '5067', 4),
    (10, '6000', 5);

INSERT INTO suburbs (suburb_id, name, postal_code_id) VALUES
    (1,  'Sydney CBD',       1), (2,  'Surry Hills',      2),
    (3,  'Wollstonecraft',   3), (4,  'Melbourne CBD',    4),
    (5,  'South Yarra',      5), (6,  'Brisbane CBD',     6),
    (7,  'South Brisbane',   7), (8,  'Adelaide CBD',     8),
    (9,  'Norwood',          9), (10, 'Perth CBD',        10);

-- Original 20 Addresses
INSERT INTO addresses (address_id, unit, number, street_1, street_2, notes, suburb_id, postal_code_id) VALUES
    (1,  NULL,  '1',   'George Street',       NULL, NULL, 1,  1),
    (2,  '2A',  '88',  'Crown Street',        NULL, NULL, 2,  2),
    (3,  NULL,  '45',  'Willoughby Road',     NULL, NULL, 3,  3),
    (4,  NULL,  '100', 'Collins Street',      NULL, NULL, 4,  4),
    (5,  NULL,  '22',  'Toorak Road',         NULL, NULL, 5,  5),
    (6,  NULL,  '300', 'Queen Street',        NULL, NULL, 6,  6),
    (7,  NULL,  '15',  'Melbourne Street',    NULL, NULL, 7,  7),
    (8,  NULL,  '55',  'King William Street', NULL, NULL, 8,  8),
    (9,  NULL,  '10',  'The Parade',          NULL, NULL, 9,  9),
    (10, NULL,  '77',  'St Georges Terrace',  NULL, NULL, 10, 10),
    (11, NULL,  '12',  'Pitt Street',         NULL, NULL, 1,  1),
    (12, NULL,  '9',   'Bourke Street',       NULL, NULL, 4,  4),
    (13, NULL,  '33',  'Elizabeth Street',    NULL, NULL, 6,  6),
    (14, NULL,  '7',   'Rundle Street',       NULL, NULL, 9,  9),
    (15, NULL,  '200', 'Murray Street',       NULL, NULL, 10, 10),
    (16, NULL,  '3',   'Flinders Lane',       NULL, NULL, 5,  5),
    (17, NULL,  '66',  'Ann Street',          NULL, NULL, 7,  7),
    (18, NULL,  '41',  'Hindley Street',      NULL, NULL, 8,  8),
    (19, NULL,  '50',  'Oxford Street',       NULL, NULL, 2,  2),
    (20, NULL,  '18',  'Pacific Highway',     NULL, NULL, 3,  3),
-- Expanded Volume Addresses (21 to 50)
    (21, 'Apt 4', '101', 'William Street',    NULL, 'Leave at reception', 1, 1),
    (22, NULL,  '42',  'Macquarie Street',    NULL, NULL, 2, 2),
    (23, 'B',   '15',  'Victoria Street',     NULL, NULL, 3, 3),
    (24, NULL,  '88',  'Lonsdale Street',     NULL, NULL, 4, 4),
    (25, '12',  '5',   'Chapel Street',       NULL, 'Beware of dog', 5, 5),
    (26, NULL,  '200', 'Edward Street',       NULL, NULL, 6, 6),
    (27, '5C',  '33',  'Boundary Street',     NULL, NULL, 7, 7),
    (28, NULL,  '99',  'Pulteney Street',     NULL, NULL, 8, 8),
    (29, NULL,  '14',  'Kensington Road',     NULL, NULL, 9, 9),
    (30, '7',   '45',  'Wellington Street',   NULL, NULL, 10, 10),
    (31, NULL,  '77',  'Sussex Street',       NULL, NULL, 1, 1),
    (32, NULL,  '10',  'Kent Street',         NULL, NULL, 1, 1),
    (33, '3',   '22',  'Clarence Street',     NULL, NULL, 1, 1),
    (34, NULL,  '100', 'Spring Street',       NULL, NULL, 4, 4),
    (35, '8A',  '12',  'Exhibition Street',   NULL, NULL, 4, 4),
    (36, NULL,  '55',  'Russell Street',      NULL, NULL, 4, 4),
    (37, NULL,  '40',  'Alice Street',        NULL, NULL, 6, 6),
    (38, '2',   '8',   'Margaret Street',     NULL, NULL, 6, 6),
    (39, NULL,  '30',  'Grote Street',        NULL, NULL, 8, 8),
    (40, NULL,  '11',  'Waymouth Street',     NULL, NULL, 8, 8),
    (41, '9',   '25',  'Hay Street',          NULL, NULL, 10, 10),
    (42, NULL,  '60',  'William Street',      NULL, NULL, 10, 10),
    (43, NULL,  '15',  'Crown Road',          NULL, NULL, 2, 2),
    (44, 'A',   '3',   'Miller Street',       NULL, NULL, 3, 3),
    (45, NULL,  '70',  'Toorak Road',         NULL, NULL, 5, 5),
    (46, '4',   '18',  'Grey Street',         NULL, NULL, 7, 7),
    (47, NULL,  '90',  'The Parade',          NULL, NULL, 9, 9),
    (48, NULL,  '120', 'St Georges Terrace',  NULL, NULL, 10, 10),
    (49, '1B',  '6',   'Pitt Street',         NULL, NULL, 1, 1),
    (50, NULL,  '80',  'Bourke Street',       NULL, NULL, 4, 4);

-- ══ DEPOTS ═══════════════════════════════════════════

INSERT INTO depots (depot_id, depot_name, notes, phone, email, address_id) VALUES
    (1, 'Sydney CBD Depot',     'Main Sydney hub',       '0281001001', 'sydney@parcelgo.com.au',    1),
    (2, 'Melbourne CBD Depot',  'Main Melbourne hub',    '0381002001', 'melbourne@parcelgo.com.au', 4),
    (3, 'Brisbane CBD Depot',   'Main Brisbane hub',     '0781003001', 'brisbane@parcelgo.com.au',  6),
    (4, 'Adelaide CBD Depot',   'Main Adelaide hub',     '0881004001', 'adelaide@parcelgo.com.au',  8),
    (5, 'Perth CBD Depot',      'Main Perth hub',        '0881005001', 'perth@parcelgo.com.au',     10);

INSERT INTO storage_slots (depot_id, storage_slot_id, zone, aisle, bay, shelf, status) VALUES
    (1, 1, 'A', 'A1', 'B1', 'S1', 'available'),
    (1, 2, 'A', 'A1', 'B2', 'S1', 'available'),
    (1, 3, 'B', 'A2', 'B1', 'S2', 'available'),
    (2, 1, 'A', 'A1', 'B1', 'S1', 'available'),
    (2, 2, 'A', 'A2', 'B1', 'S1', 'available'),
    (3, 1, 'A', 'A1', 'B1', 'S1', 'available'),
    (3, 2, 'B', 'A1', 'B2', 'S2', 'available'),
    (4, 1, 'A', 'A1', 'B1', 'S1', 'available'),
    (5, 1, 'A', 'A1', 'B1', 'S1', 'available'),
    (5, 2, 'A', 'A1', 'B2', 'S1', 'available');

-- ══ CREDENTIALS & STAFF ══════════════════════════════

-- Original Staff Credentials
INSERT INTO staff_credentials (staff_credentials_id, user_name, password, mfa, last_login, last_password_change) VALUES
    (1,  'ops.admin',     '$2b$12$hashedpw1', true,  '2026-04-20 08:00:00', '2026-01-10 09:00:00'),
    (2,  'billing.admin', '$2b$12$hashedpw2', true,  '2026-04-21 08:30:00', '2026-01-15 09:00:00'),
    (3,  'warehouse.syd', '$2b$12$hashedpw3', false, '2026-04-22 07:00:00', '2026-02-01 09:00:00'),
    (4,  'warehouse.mel', '$2b$12$hashedpw4', false, '2026-04-22 07:15:00', '2026-02-01 09:00:00'),
    (5,  'support.one',   '$2b$12$hashedpw5', false, '2026-04-21 09:00:00', '2026-02-15 09:00:00'),
    (6,  'support.two',   '$2b$12$hashedpw6', false, '2026-04-20 09:00:00', '2026-02-15 09:00:00'),
    (7,  'manager.ops',   '$2b$12$hashedpw7', true,  '2026-04-22 08:00:00', '2026-01-05 09:00:00'),
    (8,  'warehouse.bne', '$2b$12$hashedpw8', false, '2026-04-22 06:45:00', '2026-02-01 09:00:00'),
    (9,  'driver.jack',   '$2b$12$hashedpw9', false, '2026-04-22 06:00:00', '2026-01-20 09:00:00'),
    (10, 'driver.sarah',  '$2b$12$hashedpw10',false, '2026-04-22 06:10:00', '2026-01-20 09:00:00'),
    (11, 'driver.mike',   '$2b$12$hashedpw11',false, '2026-04-21 06:00:00', '2026-01-20 09:00:00'),
    (12, 'driver.lisa',   '$2b$12$hashedpw12',false, '2026-04-22 06:20:00', '2026-01-20 09:00:00'),
    (13, 'driver.tom',    '$2b$12$hashedpw13',false, '2026-04-20 06:00:00', '2026-01-20 09:00:00'),
    (14, 'driver.emma',   '$2b$12$hashedpw14',false, '2026-04-22 06:30:00', '2026-01-20 09:00:00'),
    (15, 'driver.james',  '$2b$12$hashedpw15',false, '2026-04-21 06:15:00', '2026-01-20 09:00:00'),
    (16, 'driver.olivia', '$2b$12$hashedpw16',false, '2026-04-22 06:45:00', '2026-01-20 09:00:00');

-- Expanded Credentials for New Drivers
INSERT INTO staff_credentials (staff_credentials_id, user_name, password, mfa, last_login, last_password_change)
WITH RECURSIVE seq AS (SELECT 17 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 45)
SELECT
    id,
    CONCAT('driver_user_', id),
    '$2b$12$dummyhash',
    false,
    NOW(),
    NOW()
FROM seq;

INSERT INTO staff (staff_id, first_name, last_name, mobile_phone, work_phone, email, manager_id, role_id, staff_credentials_id) VALUES
    (1, 'David',   'Nguyen',   '0411001001', '0281001100', 'david.nguyen@parcelgo.com.au',   NULL, 5, 1),
    (2, 'Rachel',  'Thompson', '0411001002', '0281001101', 'rachel.thompson@parcelgo.com.au', 1,   2, 2),
    (3, 'Ben',     'Walsh',    '0411001003', '0281001102', 'ben.walsh@parcelgo.com.au',       1,   3, 3),
    (4, 'Maria',   'Costa',    '0411001004', '0381001103', 'maria.costa@parcelgo.com.au',     1,   3, 4),
    (5, 'Simon',   'Park',     '0411001005', '0281001104', 'simon.park@parcelgo.com.au',      1,   4, 5),
    (6, 'Priya',   'Sharma',   '0411001006', '0281001105', 'priya.sharma@parcelgo.com.au',    1,   4, 6),
    (7, 'Nathan',  'Ellis',    '0411001007', '0281001106', 'nathan.ellis@parcelgo.com.au',    NULL,5, 7),
    (8, 'Claire',  'Hudson',   '0411001008', '0781001107', 'claire.hudson@parcelgo.com.au',   1,   3, 8);

-- ══ DRIVERS & VEHICLES ════════════════════════════════

-- Original Drivers
INSERT INTO drivers (driver_id, first_name, last_name, mobile_phone, email, staff_credentials_id) VALUES
    (1, 'Jack',   'Morrison',  '0421001001', 'jack.morrison@parcelgo.com.au',  9),
    (2, 'Sarah',  'Brennan',   '0421001002', 'sarah.brennan@parcelgo.com.au',  10),
    (3, 'Mike',   'Tran',      '0421001003', 'mike.tran@parcelgo.com.au',      11),
    (4, 'Lisa',   'Patel',     '0421001004', 'lisa.patel@parcelgo.com.au',     12),
    (5, 'Tom',    'Garcia',    '0421001005', 'tom.garcia@parcelgo.com.au',     13),
    (6, 'Emma',   'Wilson',    '0421001006', 'emma.wilson@parcelgo.com.au',    14),
    (7, 'James',  'Okafor',    '0421001007', 'james.okafor@parcelgo.com.au',   15),
    (8, 'Olivia', 'Chen',      '0421001008', 'olivia.chen@parcelgo.com.au',    16);

-- Expanded Drivers (Total 30)
INSERT INTO drivers (driver_id, first_name, last_name, mobile_phone, email, staff_credentials_id)
WITH RECURSIVE seq AS (SELECT 9 AS id UNION ALL SELECT id + 1 FROM seq WHERE id <= 30)
SELECT
    id,
    CONCAT('DriverFirst', id),
    CONCAT('DriverLast', id),
    CONCAT('04210010', LPAD(id, 2, '0')),
    CONCAT('driver', id, '@parcelgo.com.au'),
    id + 8
FROM seq;

INSERT INTO licenses (license_id, license_num, license_type, issued_on, state_of_issue, valid_until, driver_id) VALUES
    (1, 'NSW-DL-10001', 'Car',   '2020-03-15', 'NSW', '2028-03-15', 1),
    (2, 'NSW-DL-10002', 'Car',   '2019-06-20', 'NSW', '2027-06-20', 2),
    (3, 'VIC-DL-20001', 'Heavy', '2021-01-10', 'VIC', '2029-01-10', 3),
    (4, 'VIC-DL-20002', 'Car',   '2020-09-05', 'VIC', '2028-09-05', 4),
    (5, 'QLD-DL-30001', 'Heavy', '2018-11-30', 'QLD', '2026-11-30', 5),
    (6, 'QLD-DL-30002', 'Car',   '2022-04-18', 'QLD', '2030-04-18', 6),
    (7, 'SA-DL-40001',  'Car',   '2021-07-22', 'SA',  '2029-07-22', 7),
    (8, 'WA-DL-50001',  'Heavy', '2020-02-14', 'WA',  '2028-02-14', 8);

INSERT INTO certifications (certification_id, certification_num, certification_name, issued_on, valid_until, driver_id) VALUES
    (1, 'CERT-SAFE-001', 'Safe Driver Certificate',        '2024-01-15', '2027-01-15', 1),
    (2, 'CERT-SAFE-002', 'Safe Driver Certificate',        '2024-02-10', '2027-02-10', 2),
    (3, 'CERT-HEAVY-001','Heavy Vehicle Certification',    '2023-06-01', '2026-06-01', 3),
    (4, 'CERT-SAFE-003', 'Safe Driver Certificate',        '2024-03-20', '2027-03-20', 4),
    (5, 'CERT-HEAVY-002','Heavy Vehicle Certification',    '2023-09-15', '2026-09-15', 5),
    (6, 'CERT-SAFE-004', 'Safe Driver Certificate',        '2025-01-10', '2028-01-10', 6),
    (7, 'CERT-SAFE-005', 'Safe Driver Certificate',        '2024-07-07', '2027-07-07', 7),
    (8, 'CERT-HEAVY-003','Heavy Vehicle Certification',    '2024-04-01', '2027-04-01', 8);

INSERT INTO vehicle_types (vehicle_type_id, type_name, license_required) VALUES
    (1, 'Van',         'Car'),
    (2, 'Truck',       'Heavy'),
    (3, 'Motorcycle',  'Car'),
    (4, 'Electric Van','Car');

INSERT INTO vehicles (vehicle_id, registration, capacity, is_available, vehicle_type_id) VALUES
    (1,  'NSW-ABC-001', 800.00,  true,  1), (2,  'NSW-ABC-002', 800.00,  true,  1),
    (3,  'NSW-ABC-003', 2000.00, true,  2), (4,  'VIC-XYZ-001', 800.00,  true,  1),
    (5,  'VIC-XYZ-002', 2000.00, false, 2), (6,  'QLD-DEF-001', 800.00,  true,  1),
    (7,  'QLD-DEF-002', 300.00,  true,  3), (8,  'SA-GHI-001',  800.00,  true,  4),
    (9,  'WA-JKL-001',  800.00,  true,  1), (10, 'NSW-ABC-004', 800.00,  true,  4);

INSERT INTO vehicle_maintenances (v_maintenance_id, maintenance_date, maintenance_type, notes, status, vehicle_id, recorded_by) VALUES
    (1, '2026-03-10', 'routine',    'Regular 10,000km service',     'completed',  1, 1),
    (2, '2026-02-20', 'repair',     'Brake pad replacement',        'completed',  3, 1),
    (3, '2026-04-15', 'inspection', 'Annual roadworthy inspection', 'completed',  5, 7),
    (4, '2026-04-20', 'repair',     'Engine fault — out of service','in_progress', 5, 7),
    (5, '2026-03-25', 'routine',    'Regular 10,000km service',     'completed',  8, 1);

-- ══ CUSTOMERS & CREDENTIALS ══════════════════════════

-- Original 10 Credentials
INSERT INTO credentials (credentials_id, user_name, password, mfa, last_login, last_password_change) VALUES
    (1,  'alice.johnson',  '$2b$12$custpw1',  true,  '2026-04-22 09:00:00', '2026-01-01 00:00:00'),
    (2,  'bob.smith',      '$2b$12$custpw2',  false, '2026-04-20 14:00:00', '2026-01-15 00:00:00'),
    (3,  'carol.white',    '$2b$12$custpw3',  false, '2026-04-18 10:00:00', '2026-02-01 00:00:00'),
    (4,  'dan.brown',      '$2b$12$custpw4',  true,  '2026-04-21 11:00:00', '2026-02-10 00:00:00'),
    (5,  'eva.green',      '$2b$12$custpw5',  false, '2026-04-19 08:00:00', '2026-03-01 00:00:00'),
    (6,  'frank.lee',      '$2b$12$custpw6',  false, '2026-04-17 16:00:00', '2026-03-05 00:00:00'),
    (7,  'grace.kim',      '$2b$12$custpw7',  true,  '2026-04-22 07:30:00', '2026-03-10 00:00:00'),
    (8,  'henry.jones',    '$2b$12$custpw8',  false, '2026-04-15 13:00:00', '2026-03-15 00:00:00'),
    (9,  'irene.murphy',   '$2b$12$custpw9',  false, '2026-04-21 15:00:00', '2026-04-01 00:00:00'),
    (10, 'james.taylor',   '$2b$12$custpw10', true,  '2026-04-22 08:45:00', '2026-04-05 00:00:00');

-- Expanded Volume Credentials (11 to 40)
INSERT INTO credentials (credentials_id, user_name, password, mfa, last_login, last_password_change)
WITH RECURSIVE seq AS (SELECT 11 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 40)
SELECT id, CONCAT('user_', id), '$2b$12$dummyhash', IF(id MOD 2 = 0, true, false), NOW(), NOW() FROM seq;

-- Original 10 Customers
INSERT INTO customers (customer_id, first_name, last_name, dob, account_status, credentials_id, billing_details_id) VALUES
    (1,  'Alice',  'Johnson', '1990-05-14', 'active',    1,  NULL),
    (2,  'Bob',    'Smith',   '1985-08-22', 'active',    2,  NULL),
    (3,  'Carol',  'White',   '1992-11-03', 'active',    3,  NULL),
    (4,  'Dan',    'Brown',   '1978-02-28', 'active',    4,  NULL),
    (5,  'Eva',    'Green',   '1995-07-19', 'active',    5,  NULL),
    (6,  'Frank',  'Lee',     '1988-12-01', 'suspended', 6,  NULL),
    (7,  'Grace',  'Kim',     '1993-04-25', 'active',    7,  NULL),
    (8,  'Henry',  'Jones',   '1970-09-10', 'active',    8,  NULL),
    (9,  'Irene',  'Murphy',  '1998-01-30', 'active',    9,  NULL),
    (10, 'James',  'Taylor',  '1982-06-17', 'active',    10, NULL);

-- Expanded Volume Customers (11 to 40)
INSERT INTO customers (customer_id, first_name, last_name, dob, account_status, credentials_id, billing_details_id)
WITH RECURSIVE seq AS (SELECT 11 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 40)
SELECT id, CONCAT('FirstName', id), CONCAT('LastName', id), DATE_ADD('1980-01-01', INTERVAL id MONTH), 'active', id, NULL FROM seq;

-- Original Customer Addresses
INSERT INTO customer_addresses (customer_id, address_id, label, is_default) VALUES
    (1,  11, 'Home',   true),  (1,  2,  'Work',   false),
    (2,  12, 'Home',   true),  (3,  13, 'Home',   true),
    (4,  14, 'Home',   true),  (4,  9,  'Work',   false),
    (5,  15, 'Home',   true),  (6,  16, 'Home',   true),
    (7,  17, 'Home',   true),  (8,  18, 'Home',   true),
    (9,  19, 'Home',   true),  (9,  2,  'Work',   false),
    (10, 20, 'Home',   true),  (10, 3,  'Office', false);

-- Expanded Customer Addresses
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
WITH RECURSIVE seq AS (SELECT 11 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 40)
SELECT id, id + 10, 'Primary', true FROM seq;

-- Original Contact Details
INSERT INTO contact_details (contact_detail_id, contact_value, contact_info, use_for_notification, channel_type_id, customer_id) VALUES
    (1,  'alice.johnson@email.com',  NULL, true,  1, 1),
    (2,  '+61411001011',             NULL, true,  2, 1),
    (3,  'bob.smith@email.com',      NULL, true,  1, 2),
    (4,  'carol.white@email.com',    NULL, true,  1, 3),
    (5,  '+61411001014',             NULL, false, 2, 3),
    (6,  'dan.brown@email.com',      NULL, true,  1, 4),
    (7,  'eva.green@email.com',      NULL, true,  1, 5),
    (8,  '+61411001017',             NULL, true,  2, 5),
    (9,  'frank.lee@email.com',      NULL, true,  1, 6),
    (10, 'grace.kim@email.com',      NULL, true,  1, 7),
    (11, 'henry.jones@email.com',    NULL, true,  1, 8),
    (12, 'irene.murphy@email.com',   NULL, true,  1, 9),
    (13, '+61411001022',             NULL, true,  2, 9),
    (14, 'james.taylor@email.com',   NULL, true,  1, 10);

-- Expanded Contact Details
INSERT INTO contact_details (contact_value, use_for_notification, channel_type_id, customer_id)
WITH RECURSIVE seq AS (SELECT 11 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 40)
SELECT CONCAT('customer', id, '@email.com'), true, 1, id FROM seq;

-- Original Billing Details
INSERT INTO billing_details (billing_detail_id, billing_name, notes, customer_id, address_id, payment_method_id) VALUES
    (1,  'Alice Johnson',  NULL, 1,  11, 1),
    (2,  'Bob Smith',      NULL, 2,  12, 3),
    (3,  'Carol White',    NULL, 3,  13, 1),
    (4,  'Dan Brown',      NULL, 4,  14, 2),
    (5,  'Eva Green',      NULL, 5,  15, 1),
    (6,  'Frank Lee',      NULL, 6,  16, 3),
    (7,  'Grace Kim',      NULL, 7,  17, 1),
    (8,  'Henry Jones',    NULL, 8,  18, 2),
    (9,  'Irene Murphy',   NULL, 9,  19, 1),
    (10, 'James Taylor',   NULL, 10, 20, 3);

-- Expanded Billing Details
INSERT INTO billing_details (billing_detail_id, billing_name, customer_id, address_id, payment_method_id)
WITH RECURSIVE seq AS (SELECT 11 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 40)
SELECT id, CONCAT('FirstName', id, ' LastName', id), id, id + 10, IF(id MOD 3 = 0, 1, IF(id MOD 2 = 0, 2, 3)) FROM seq;

-- Link Billing Details to all Customers
UPDATE customers SET billing_details_id = customer_id WHERE customer_id >= 1;

-- ══ ROUTES & ASSIGNMENTS ═════════════════════════════

INSERT INTO routes (route_id, route_name, origin, destination, distance, duration_estim, service_type, route_type) VALUES
    (1,  'SYD Pickup Run 1',       11,  1,   15.2, 0.50, 'standard', 'pickup'),
    (2,  'SYD Metro Delivery 1',   1,   11,  15.2, 0.50, 'standard', 'delivery'),
    (3,  'SYD Metro Delivery 2',   1,   19,  18.5, 0.75, 'express',  'delivery'),
    (4,  'SYD-MEL Inter-Depot',    1,   4,   877.0,10.00,'standard', 'inter-depot'),
    (5,  'MEL Metro Delivery 1',   4,   12,  12.0, 0.50, 'standard', 'delivery'),
    (6,  'MEL Metro Delivery 2',   4,   16,  14.5, 0.60, 'express',  'delivery'),
    (7,  'BNE Pickup Run 1',       13,  6,   10.0, 0.40, 'standard', 'pickup'),
    (8,  'BNE Metro Delivery 1',   6,   13,  10.0, 0.40, 'standard', 'delivery'),
    (9,  'BNE Metro Delivery 2',   6,   17,  8.5,  0.35, 'eco',      'delivery'),
    (10, 'ADL Metro Delivery 1',   8,   14,  11.0, 0.45, 'standard', 'delivery'),
    (11, 'PER Metro Delivery 1',   10,  15,  9.5,  0.40, 'standard', 'delivery'),
    (12, 'SYD Express Delivery 1', 1,   20,  22.0, 0.80, 'express',  'delivery');

INSERT INTO assignments (assignment_id, created_at, start_at, end_at, status, route_id, vehicle_id, driver_id) VALUES
    (1,  '2026-04-01 07:00:00', '2026-04-01 08:00:00', '2026-04-01 10:00:00', 'completed',   1,  1,  1),
    (2,  '2026-04-01 07:00:00', '2026-04-01 11:00:00', '2026-04-01 14:00:00', 'completed',   2,  1,  1),
    (3,  '2026-04-05 07:00:00', '2026-04-05 08:00:00', '2026-04-05 10:30:00', 'completed',   3,  2,  2),
    (4,  '2026-04-06 06:00:00', '2026-04-06 07:00:00', '2026-04-06 18:00:00', 'completed',   4,  3,  3),
    (5,  '2026-04-07 07:00:00', '2026-04-07 08:00:00', '2026-04-07 11:00:00', 'completed',   5,  4,  4),
    (6,  '2026-04-08 07:00:00', '2026-04-08 08:00:00', '2026-04-08 10:00:00', 'completed',   6,  4,  4),
    (7,  '2026-04-10 07:00:00', '2026-04-10 08:00:00', '2026-04-10 10:30:00', 'completed',   7,  6,  5),
    (8,  '2026-04-10 07:00:00', '2026-04-10 11:00:00', '2026-04-10 14:00:00', 'completed',   8,  6,  5),
    (9,  '2026-04-12 07:00:00', '2026-04-12 08:00:00', '2026-04-12 10:00:00', 'completed',   9,  7,  6),
    (10, '2026-04-15 07:00:00', '2026-04-15 08:00:00', '2026-04-15 11:00:00', 'completed',   10, 8,  7),
    (11, '2026-04-18 07:00:00', '2026-04-18 08:00:00', '2026-04-18 11:00:00', 'completed',   11, 9,  8),
    (12, '2026-04-20 07:00:00', '2026-04-20 08:00:00', NULL,                  'in_progress', 12, 10, 1),
    (13, '2026-04-22 07:00:00', '2026-04-22 08:00:00', NULL,                  'in_progress', 1,  1,  2),
    (14, '2026-04-23 07:00:00', NULL,                  NULL,                  'scheduled',   2,  2,  1),
    (15, '2026-04-23 07:00:00', NULL,                  NULL,                  'scheduled',   5,  4,  3);

-- Expanded Assignments (Performance bias for top performers query)
INSERT INTO assignments (assignment_id, created_at, start_at, end_at, status, route_id, vehicle_id, driver_id)
WITH RECURSIVE seq AS (SELECT 16 AS id UNION ALL SELECT id + 1 FROM seq WHERE id <= 200)
SELECT
    id,
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY),
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY),
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY),
    'completed',
    FLOOR(RAND() * 6) + 1,
    FLOOR(RAND() * 10) + 1,
    CASE
        WHEN id <= 150 THEN FLOOR(RAND() * 12) + 1
        ELSE FLOOR(RAND() * 18) + 13
        END
FROM seq;

-- ══ ORDERS & PARCELS ═════════════════════════════════

-- Original 20 Orders
INSERT INTO orders (order_id, total_weight, placed_at, status, notes, customer_id) VALUES
    (1,  3.50, '2026-04-01 09:00:00', 'delivered',   NULL,                      1),
    (2,  1.20, '2026-04-01 09:30:00', 'delivered',   NULL,                      2),
    (3,  5.80, '2026-04-05 10:00:00', 'delivered',   NULL,                      3),
    (4,  2.10, '2026-04-06 08:00:00', 'delivered',   'Inter-state delivery',    4),
    (5,  4.00, '2026-04-08 11:00:00', 'delivered',   NULL,                      5),
    (6,  7.50, '2026-04-10 08:30:00', 'in_transit',  NULL,                      1),
    (7,  1.80, '2026-04-10 09:00:00', 'in_transit',  NULL,                      7),
    (8,  3.20, '2026-04-12 07:30:00', 'in_transit',  'Eco delivery requested',  8),
    (9,  6.00, '2026-04-15 10:00:00', 'in_transit',  NULL,                      9),
    (10, 2.50, '2026-04-18 09:00:00', 'in_transit',  NULL,                      10),
    (11, 1.50, '2026-04-20 08:00:00', 'confirmed',   NULL,                      2),
    (12, 4.50, '2026-04-20 10:00:00', 'confirmed',   NULL,                      3),
    (13, 0.80, '2026-04-21 09:00:00', 'confirmed',   'Document envelope',       4),
    (14, 3.00, '2026-04-21 14:00:00', 'confirmed',   NULL,                      5),
    (15, 2.20, '2026-04-22 08:30:00', 'confirmed',   NULL,                      6),
    (16, 1.10, '2026-04-22 09:00:00', 'draft',       NULL,                      7),
    (17, 5.50, '2026-04-22 09:30:00', 'draft',       NULL,                      8),
    (18, 0.60, '2026-04-22 10:00:00', 'draft',       'Urgent document',         9),
    (19, 2.80, '2026-04-10 11:00:00', 'cancelled',   'Customer cancelled',      6),
    (20, 3.10, '2026-04-18 10:00:00', 'delivered',   'Failed first attempt – retry', 10);

-- Expanded Volume Orders (21 to 100)
INSERT INTO orders (order_id, total_weight, placed_at, status, notes, customer_id)
WITH RECURSIVE seq AS (SELECT 21 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 100)
SELECT
    id,
    ROUND(RAND() * 10 + 1, 2),
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY),
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'draft'
        WHEN 1 THEN 'confirmed'
        WHEN 2 THEN 'in_transit'
        WHEN 3 THEN 'delivered'
        ELSE 'delivered'
        END,
    IF(id MOD 5 = 0, 'Signature required', NULL),
    FLOOR(RAND() * 39) + 1
FROM seq;

-- Original Parcels
INSERT INTO parcels (parcel_id, weight, height, width, length, notes, lifecycle_status_id, parcel_category_id, pickup_add_id, delivery_add_id, order_id) VALUES
    (1,  2.00, 30.0, 20.0, 15.0, NULL,                      6, 1, 11, 11, 1),
    (2,  1.50, 20.0, 15.0, 10.0, 'Handle with care',        2, 2, 11, 2,  1),
    (3,  1.20, 25.0, 18.0, 12.0, NULL,                      6, 5, 12, 12, 2),
    (4,  3.00, 40.0, 30.0, 20.0, NULL,                      6, 1, 13, 13, 3),
    (5,  2.80, 35.0, 25.0, 18.0, 'Fragile — glass',         6, 2, 13, 2,  3),
    (6,  2.10, 28.0, 22.0, 16.0, NULL,                      6, 1, 14, 12, 4),
    (7,  2.50, 32.0, 24.0, 18.0, NULL,                      6, 1, 15, 16, 5),
    (8,  1.50, 22.0, 16.0, 12.0, NULL,                      6, 1, 15, 5,  5),
    (9,  4.00, 45.0, 35.0, 25.0, NULL,                      4, 1, 11, 11, 6),
    (10, 3.50, 40.0, 30.0, 22.0, 'Do not stack',            4, 4, 11, 11, 6),
    (11, 1.80, 26.0, 20.0, 14.0, NULL,                      4, 1, 17, 13, 7),
    (12, 1.80, 24.0, 18.0, 13.0, 'Eco delivery',            4, 1, 18, 17, 8),
    (13, 1.40, 20.0, 15.0, 11.0, NULL,                      4, 1, 18, 7,  8),
    (14, 3.50, 38.0, 28.0, 20.0, NULL,                      4, 1, 19, 14, 9),
    (15, 2.50, 30.0, 22.0, 16.0, NULL,                      5, 1, 19, 9,  9),
    (16, 2.50, 30.0, 22.0, 16.0, NULL,                      4, 1, 20, 15, 10),
    (17, 1.50, 22.0, 18.0, 14.0, NULL,                      2, 1, 12, 19, 11),
    (18, 2.50, 30.0, 22.0, 16.0, NULL,                      2, 2, 13, 11, 12),
    (19, 2.00, 28.0, 20.0, 15.0, 'Glass — fragile',         2, 2, 13, 2,  12),
    (20, 0.80, 30.0, 22.0, 1.0,  'Contract documents',      2, 5, 14, 12, 13),
    (21, 3.00, 35.0, 25.0, 20.0, NULL,                      2, 1, 15, 17, 14),
    (22, 2.20, 28.0, 22.0, 16.0, NULL,                      2, 1, 16, 16, 15),
    (23, 1.10, 20.0, 15.0, 10.0, NULL,                      1, 1, 17, 13, 16),
    (24, 3.00, 35.0, 25.0, 20.0, NULL,                      1, 1, 18, 12, 17),
    (25, 2.50, 30.0, 22.0, 16.0, 'Perishable — keep cool',  1, 3, 18, 4,  17),
    (26, 0.60, 32.0, 22.0, 1.0,  'Urgent contract',         1, 5, 19, 20, 18),
    (27, 2.80, 30.0, 22.0, 18.0, 'Cancelled by customer',   7, 1, 16, 12, 19),
    (28, 1.80, 26.0, 20.0, 14.0, 'Retry successful',        6, 1, 20, 15, 20),
    (29, 1.30, 22.0, 16.0, 12.0, NULL,                      6, 1, 20, 15, 20);

-- Expanded Volume Parcels (30 to 150)
INSERT INTO parcels (parcel_id, weight, height, width, length, lifecycle_status_id, parcel_category_id, pickup_add_id, delivery_add_id, order_id)
WITH RECURSIVE seq AS (SELECT 30 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 150)
SELECT
    id,
    ROUND(RAND() * 5 + 0.5, 2),
    ROUND(RAND() * 40 + 10, 2),
    ROUND(RAND() * 30 + 10, 2),
    ROUND(RAND() * 30 + 10, 2),
    CASE FLOOR(RAND() * 6)
        WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 4 WHEN 3 THEN 5 WHEN 4 THEN 6 ELSE 6
        END,
    FLOOR(RAND() * 5) + 1,
    FLOOR(RAND() * 20) + 1,
    FLOOR(RAND() * 30) + 20,
    FLOOR(RAND() * 80) + 20
FROM seq;

INSERT INTO assignment_parcels (assignment_id, parcel_id, created_at, created_by) VALUES
    (1,  1,  '2026-04-01 07:30:00', 3),
    (1,  2,  '2026-04-01 07:30:00', 3),
    (1,  3,  '2026-04-01 07:30:00', 3),
    (2,  1,  '2026-04-01 10:30:00', 3),
    (2,  3,  '2026-04-01 10:30:00', 3),
    (3,  4,  '2026-04-05 07:30:00', 3),
    (3,  5,  '2026-04-05 07:30:00', 3),
    (4,  6,  '2026-04-06 06:30:00', 3),
    (5,  6,  '2026-04-07 07:30:00', 3),
    (5,  7,  '2026-04-07 07:30:00', 3),
    (5,  8,  '2026-04-07 07:30:00', 3),
    (6,  7,  '2026-04-08 07:30:00', 3),
    (6,  8,  '2026-04-08 07:30:00', 3),
    (7,  11, '2026-04-10 07:30:00', 8),
    (8,  9,  '2026-04-10 10:30:00', 3),
    (8,  10, '2026-04-10 10:30:00', 3),
    (8,  11, '2026-04-10 10:30:00', 3),
    (9,  12, '2026-04-12 07:30:00', 8),
    (9,  13, '2026-04-12 07:30:00', 8),
    (10, 14, '2026-04-15 07:30:00', 3),
    (10, 15, '2026-04-15 07:30:00', 3),
    (11, 16, '2026-04-18 07:30:00', 3),
    (11, 28, '2026-04-18 07:30:00', 3),
    (11, 29, '2026-04-18 07:30:00', 3),
    (12, 17, '2026-04-20 07:30:00', 3),
    (12, 18, '2026-04-20 07:30:00', 3),
    (12, 19, '2026-04-20 07:30:00', 3),
    (13, 20, '2026-04-22 07:30:00', 8),
    (13, 21, '2026-04-22 07:30:00', 8);


-- ══ TRACKING EVENTS ══════════════════════════════════

-- Original Tracking Events
INSERT INTO tracking_events (tracking_event_id, created_at, notes, event_type_id, assignment_id, parcel_id, address_id, staff_id) VALUES
    (1, '2026-04-01 08:30:00', NULL, 1, 1, 1, 11, NULL),
    (2, '2026-04-01 09:00:00', NULL, 2, 1, 1, 1, 3),
    (3, '2026-04-01 09:15:00', NULL, 3, 1, 1, 1, 3),
    (4, '2026-04-01 12:30:00', NULL, 4, 2, 1, 1, 3),
    (5, '2026-04-01 13:45:00', NULL, 5, 2, 1, 11, NULL),
    (6, '2026-04-01 08:30:00', NULL, 1, 1, 3, 12, NULL),
    (7, '2026-04-01 09:00:00', NULL, 2, 1, 3, 1, 3),
    (8, '2026-04-01 13:00:00', NULL, 5, 2, 3, 12, NULL),
    (9, '2026-04-05 08:30:00', NULL, 1, 3, 4, 13, NULL),
    (10, '2026-04-05 09:30:00', NULL, 2, 3, 4, 6, 8),
    (11, '2026-04-05 09:45:00', NULL, 3, 3, 4, 6, 8),
    (12, '2026-04-05 10:00:00', NULL, 4, 3, 4, 6, 8),
    (13, '2026-04-05 10:15:00', NULL, 5, 3, 4, 13, NULL),
    (14, '2026-04-06 08:00:00', NULL, 1, 4, 6, 14, NULL),
    (15, '2026-04-06 10:00:00', NULL, 2, 4, 6, 1, 3),
    (16, '2026-04-07 08:30:00', NULL, 4, 5, 6, 4, 4),
    (17, '2026-04-07 10:30:00', NULL, 5, 5, 6, 12, NULL),
    (18, '2026-04-10 08:30:00', NULL, 1, 7, 11, 17, NULL),
    (19, '2026-04-10 09:00:00', NULL, 2, 7, 11, 6, 8),
    (20, '2026-04-10 09:15:00', NULL, 3, 7, 11, 6, 8),
    (21, '2026-04-10 11:30:00', NULL, 4, 8, 9, 6, 8),
    (22, '2026-04-12 08:30:00', NULL, 1, 9, 12, 18, NULL),
    (23, '2026-04-12 09:00:00', NULL, 2, 9, 12, 3, 3),
    (24, '2026-04-15 08:30:00', NULL, 1, 10, 14, 19, NULL),
    (25, '2026-04-15 09:00:00', NULL, 2, 10, 14, 8, 3),
    (26, '2026-04-18 08:30:00', NULL, 1, 11, 28, 20, NULL),
    (27, '2026-04-18 09:30:00', 'No one home — retry tomorrow', 6, 11, 28, 15, NULL),
    (28, '2026-04-19 09:00:00', NULL, 5, 11, 28, 15, NULL);

-- Expanded Tracking Events (Arrivals)
INSERT INTO tracking_events (created_at, event_type_id, parcel_id, address_id, staff_id)
SELECT
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 10) DAY),
    2, -- Depot Arrival
    parcel_id,
    pickup_add_id,
    3  -- Fixed staff for simplicity
FROM parcels
WHERE lifecycle_status_id IN (4, 5, 6) AND parcel_id >= 30;

-- Expanded Tracking Events (Deliveries)
INSERT INTO tracking_events (created_at, event_type_id, parcel_id, address_id, staff_id)
SELECT
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 5) DAY),
    5, -- Delivered
    parcel_id,
    delivery_add_id,
    NULL
FROM parcels
WHERE lifecycle_status_id = 6 AND parcel_id >= 30;


-- ══ PARCEL SLOT ASSIGNMENTS ══════════════
INSERT INTO parcel_slot_assignments (parcel_id, slot_assignment_id, check_in_at, check_out_at, handling_status, alert_flag, depot_id, storage_slot_id) VALUES
    (1,  1, '2026-04-01 09:15:00', '2026-04-01 12:00:00', 'checked_out', false, 1, 1),
    (3,  2, '2026-04-01 09:15:00', '2026-04-01 12:00:00', 'checked_out', false, 1, 2),
    (4,  3, '2026-04-05 09:45:00', '2026-04-05 11:00:00', 'checked_out', false, 3, 1),
    (6,  4, '2026-04-06 10:00:00', '2026-04-06 11:00:00', 'checked_out', false, 1, 1),
    (9,  5, '2026-04-10 09:30:00', NULL,                  'in_storage',  false, 3, 2),
    (10, 6, '2026-04-10 09:30:00', NULL,                  'in_storage',  false, 3, 2),
    (11, 7, '2026-04-10 09:15:00', NULL,                  'in_storage',  false, 3, 1),
    (12, 8, '2026-04-12 09:00:00', NULL,                  'in_storage',  false, 1, 3),
    (14, 9, '2026-04-15 09:00:00', NULL,                  'in_storage',  false, 4, 1),
    (16,10, '2026-04-18 08:00:00', NULL,                  'in_storage',  false, 5, 1);


-- ══ SUSTAINABILITY ═══════════════════════
INSERT INTO gp_accounts (gp_account_id, gp_balance, customer_id) VALUES
    (1,  125.00, 1),  (2,  40.00,  2),
    (3,  0.00,   3),  (4,  80.00,  4),
    (5,  200.00, 5),  (6,  0.00,   6),
    (7,  55.00,  7),  (8,  30.00,  8),
    (9,  90.00,  9),  (10, 110.00, 10);

INSERT INTO emission_records (emission_record_id, emission_amount, baseline, emissions_saved, assignment_id) VALUES
    (1,  2.40, 3.20, 0.80, 1), (2,  1.80, 3.20, 1.40, 2),
    (3,  3.50, 4.50, 1.00, 3), (4,  8.20, 9.00, 0.80, 4),
    (5,  2.10, 3.00, 0.90, 5), (6,  1.90, 2.80, 0.90, 6),
    (7,  1.50, 2.20, 0.70, 7), (8,  2.80, 3.50, 0.70, 8),
    (9,  1.20, 2.50, 1.30, 9), (10, 2.60, 3.40, 0.80, 10),
    (11, 2.20, 3.10, 0.90, 11), (12, 1.90, 2.80, 0.90, 12);

INSERT INTO gp_transactions (transaction_id, transaction_at, transaction_type, gp_amount, expiry_date, emission_record_id, gp_account_id) VALUES
    (1,  '2026-04-01 14:00:00', 'earned',   8.00,  '2027-04-01', 1,  1),
    (2,  '2026-04-01 14:00:00', 'earned',   14.00, '2027-04-01', 2,  1),
    (3,  '2026-04-01 14:00:00', 'earned',   14.00, '2027-04-01', 2,  2),
    (4,  '2026-04-05 11:00:00', 'earned',   10.00, '2027-04-05', 3,  3),
    (5,  '2026-04-07 12:00:00', 'earned',   9.00,  '2027-04-07', 5,  4),
    (6,  '2026-04-08 11:00:00', 'earned',   9.00,  '2027-04-08', 6,  5),
    (7,  '2026-04-10 15:00:00', 'earned',   7.00,  '2027-04-10', 7,  7),
    (8,  '2026-04-12 11:00:00', 'earned',   13.00, '2027-04-12', 9,  8),
    (9,  '2026-04-15 12:00:00', 'earned',   8.00,  '2027-04-15', 10, 9),
    (10, '2026-04-18 12:00:00', 'earned',   9.00,  '2027-04-18', 11, 10),
    (11, '2026-04-10 10:00:00', 'redeemed', -25.00, NULL,         1, 1),
    (12, '2026-03-01 10:00:00', 'expired',  -5.00,  NULL,         1, 3);

INSERT INTO sustainability_reports (gp_account_id, report_id, start_date, end_date, total_emissions, total_saved, eco_option_usage) VALUES
    (1, 1, '2026-04-01', '2026-04-30', 4.20, 2.20, 'standard'),
    (2, 1, '2026-04-01', '2026-04-30', 1.80, 1.40, 'standard'),
    (5, 1, '2026-04-01', '2026-04-30', 1.90, 0.90, 'eco'),
    (9, 1, '2026-04-01', '2026-04-30', 2.60, 0.80, 'standard');


-- ══ BILLING & INVOICES ════════════════════════════════

INSERT INTO invoices (invoice_id, billing_period, invoiced_at, status, total_amount, currency, billing_detail_id, discount_rule_id) VALUES
    (1,  'April 2026', '2026-04-01 14:00:00', 'paid',    20.50,  'AUD', 1,  NULL),
    (2,  'April 2026', '2026-04-01 14:00:00', 'paid',    8.50,   'AUD', 2,  NULL),
    (3,  'April 2026', '2026-04-05 11:00:00', 'paid',    24.00,  'AUD', 3,  NULL),
    (4,  'April 2026', '2026-04-06 19:00:00', 'paid',    22.00,  'AUD', 4,  NULL),
    (5,  'April 2026', '2026-04-08 11:00:00', 'paid',    28.00,  'AUD', 5,  1),
    (6,  'April 2026', '2026-04-10 15:00:00', 'issued',  36.00,  'AUD', 1,  NULL),
    (7,  'April 2026', '2026-04-10 15:00:00', 'issued',  12.00,  'AUD', 7,  NULL),
    (8,  'April 2026', '2026-04-12 11:00:00', 'issued',  16.00,  'AUD', 8,  NULL),
    (9,  'April 2026', '2026-04-15 12:00:00', 'issued',  38.00,  'AUD', 9,  2),
    (10, 'April 2026', '2026-04-18 12:00:00', 'issued',  22.00,  'AUD', 10, NULL),
    (11, 'April 2026', '2026-04-20 09:00:00', 'draft',   12.00,  'AUD', 2,  NULL),
    (12, 'April 2026', '2026-04-20 10:30:00', 'draft',   26.00,  'AUD', 3,  NULL),
    (13, 'April 2026', '2026-04-21 09:30:00', 'draft',   8.50,   'AUD', 4,  NULL),
    (14, 'April 2026', '2026-04-21 14:30:00', 'draft',   18.00,  'AUD', 5,  NULL),
    (15, 'April 2026', '2026-04-22 09:00:00', 'draft',   11.00,  'AUD', 6,  NULL),
    (16, 'April 2026', '2026-04-18 12:00:00', 'paid',    24.00,  'AUD', 10, NULL),
    (17, 'April 2026', '2026-04-10 12:00:00', 'cancelled','0.00', 'AUD', 6,  NULL);

-- Expanded Volume Invoices (18 to 90)
INSERT INTO invoices (invoice_id, billing_period, invoiced_at, status, total_amount, currency, billing_detail_id)
WITH RECURSIVE seq AS (SELECT 18 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 90)
SELECT
    id,
    'April 2026',
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 20) DAY),
    CASE FLOOR(RAND() * 4) WHEN 0 THEN 'draft' WHEN 1 THEN 'issued' WHEN 2 THEN 'paid' ELSE 'paid' END,
    ROUND(RAND() * 50 + 10, 2),
    'AUD',
    FLOOR(RAND() * 30) + 1
FROM seq;

-- 1. Create 15 new overdue invoices (Using IDs 200 to 214 to avoid conflicts)
INSERT INTO invoices (invoice_id, billing_period, invoiced_at, status, total_amount, currency, billing_detail_id)
WITH RECURSIVE seq AS (SELECT 200 AS id UNION ALL SELECT id + 1 FROM seq WHERE id <= 214)
SELECT
    id,
    'March 2026',
    DATE_SUB(NOW(), INTERVAL (30 + (id - 200)) DAY), -- Dates from 30 to 44 days ago
    'overdue',
    CASE id MOD 3
        WHEN 0 THEN 45.00
        WHEN 1 THEN 85.00
        ELSE 30.00
        END,
    'AUD',
    (id MOD 20) + 1 -- Assigns to random customers/billing details from 1 to 20
FROM seq;

-- RESTAURADO: Invoice Lines Originales (24 líneas clave)
INSERT INTO invoice_lines (invoice_id, line_id, description, quantity, unit_price, line_amount, discount_rule_id, rate_id, parcel_id) VALUES
    (1,  1, 'Standard Metro delivery – 2kg',   1, 8.50,  8.50,  NULL, 1,  1),
    (1,  2, 'Standard Metro delivery – 1.5kg', 1, 12.00, 12.00, NULL, 2,  2),
    (2,  1, 'Standard Metro delivery – 1.2kg', 1, 8.50,  8.50,  NULL, 1,  3),
    (3,  1, 'Standard Metro delivery – 3kg',   1, 12.00, 12.00, NULL, 2,  4),
    (3,  2, 'Standard Metro delivery – 2.8kg', 1, 12.00, 12.00, NULL, 2,  5),
    (4,  1, 'Inter-state delivery – 2.1kg',    1, 22.00, 22.00, NULL, 10, 6),
    (5,  1, 'Express Metro delivery – 2.5kg',  1, 14.00, 14.00, 1,    4,  7),
    (5,  2, 'Express Metro delivery – 1.5kg',  1, 14.00, 14.00, 1,    4,  8),
    (6,  1, 'Standard Metro delivery – 4kg',   1, 18.00, 18.00, NULL, 3,  9),
    (6,  2, 'Standard Metro delivery – 3.5kg', 1, 18.00, 18.00, NULL, 3,  10),
    (7,  1, 'Standard Metro delivery – 1.8kg', 1, 12.00, 12.00, NULL, 2,  11),
    (8,  1, 'Eco Metro delivery – 1.8kg',      1, 7.00,  7.00,  NULL, 13, 12),
    (8,  2, 'Eco Metro delivery – 1.4kg',      1, 7.00,  7.00,  NULL, 13, 13),
    (9,  1, 'Standard Regional – 3.5kg',       1, 16.00, 16.00, 2,    7,  14),
    (9,  2, 'Standard Regional – 2.5kg',       1, 16.00, 16.00, 2,    7,  15),
    (10, 1, 'Standard Metro delivery – 2.5kg', 1, 12.00, 12.00, NULL, 2,  16),
    (11, 1, 'Standard Metro delivery – 1.5kg', 1, 12.00, 12.00, NULL, 2,  17),
    (12, 1, 'Standard Metro delivery – 2.5kg', 1, 12.00, 12.00, NULL, 2,  18),
    (12, 2, 'Standard Metro delivery – 2kg',   1, 14.00, 14.00, NULL, 4,  19),
    (13, 1, 'Document delivery – 0.8kg',       1, 8.50,  8.50,  NULL, 1,  20),
    (14, 1, 'Standard Metro delivery – 3kg',   1, 18.00, 18.00, NULL, 3,  21),
    (15, 1, 'Standard Metro delivery – 2.2kg', 1, 11.00, 11.00, NULL, 6,  22),
    (16, 1, 'Standard Metro delivery – 1.8kg', 1, 12.00, 12.00, NULL, 2,  28),
    (16, 2, 'Standard Metro delivery – 1.3kg', 1, 12.00, 12.00, NULL, 2,  29);

-- Expanded Volume Invoice Lines
INSERT INTO invoice_lines (invoice_id, line_id, description, quantity, unit_price, line_amount, rate_id, parcel_id)
WITH RECURSIVE seq AS (SELECT 18 AS id UNION ALL SELECT id + 1 FROM seq WHERE id < 90)
SELECT
    id,
    1,
    'Standard delivery service',
    1,
    15.00,
    15.00,
    1,
    FLOOR(RAND() * 120) + 30
FROM seq;

-- 2. Create invoice lines for those 15 overdue invoices
INSERT INTO invoice_lines (invoice_id, line_id, description, quantity, unit_price, line_amount, rate_id, parcel_id)
WITH RECURSIVE seq AS (SELECT 200 AS id UNION ALL SELECT id + 1 FROM seq WHERE id <= 214)
SELECT
    id,
    1,
    'Overdue delivery service charge',
    1,
    CASE id MOD 3
        WHEN 0 THEN 45.00
        WHEN 1 THEN 85.00
        ELSE 30.00
        END,
    CASE id MOD 3
        WHEN 0 THEN 45.00
        WHEN 1 THEN 85.00
        ELSE 30.00
        END,
    CASE id MOD 3
        WHEN 0 THEN 1  -- rate_id 1 corresponds to 'standard'
        WHEN 1 THEN 4  -- rate_id 4 corresponds to 'express'
        ELSE 13        -- rate_id 13 corresponds to 'eco'
        END,
    id - 100 -- Assigns existing parcel_ids (100 to 114)
FROM seq;

INSERT INTO payments (payment_id, transaction_ref, transaction_at, amount, currency, status, failure_reason, payment_method_id, invoice_id) VALUES
    (1,  'TXN-20260401-001', '2026-04-01 14:30:00', 20.50, 'AUD', 'completed', NULL,                    1, 1),
    (2,  'TXN-20260401-002', '2026-04-01 14:35:00', 8.50,  'AUD', 'completed', NULL,                    3, 2),
    (3,  'TXN-20260405-001', '2026-04-05 11:30:00', 24.00, 'AUD', 'completed', NULL,                    1, 3),
    (4,  'TXN-20260406-001', '2026-04-06 19:30:00', 22.00, 'AUD', 'completed', NULL,                    2, 4),
    (5,  'TXN-20260408-001', '2026-04-08 11:30:00', 14.00, 'AUD', 'failed',    'Card declined',         1, 5),
    (6,  'TXN-20260408-002', '2026-04-08 11:45:00', 28.00, 'AUD', 'completed', NULL,                    1, 5),
    (7,  'TXN-20260418-001', '2026-04-18 13:00:00', 12.00, 'AUD', 'failed',    'Insufficient funds',    3, 16),
    (8,  'TXN-20260418-002', '2026-04-18 13:30:00', 24.00, 'AUD', 'completed', NULL,                    3, 16);

INSERT INTO refunds (payment_id, refund_id, refunded_at, amount, reason, status, payment_method_id) VALUES
    (3, 1, '2026-04-07 10:00:00', 12.00, 'Partial refund — one parcel returned', 'processed', 1);

-- Expanded Volume Payments (For paid invoices)
INSERT INTO payments (transaction_ref, transaction_at, amount, currency, status, payment_method_id, invoice_id)
SELECT
    CONCAT('TXN-MASS-', invoice_id),
    DATE_ADD(invoiced_at, INTERVAL 1 DAY),
    total_amount,
    'AUD',
    'completed',
    FLOOR(RAND() * 3) + 1,
    invoice_id
FROM invoices
WHERE status = 'paid' AND invoice_id >= 18;

-- ══ COMMUNICATIONS ═════════════════════════
INSERT INTO chat_sessions (chat_session_id, session_id, started_at, last_chat_at, status, staff_id, customer_id) VALUES
    (1, 1001, '2026-04-08 10:00:00', '2026-04-08 10:25:00', 'closed',    5, 5),
    (2, 1002, '2026-04-10 14:00:00', '2026-04-10 14:40:00', 'closed',    6, 1),
    (3, 1003, '2026-04-19 09:00:00', '2026-04-19 09:20:00', 'archived',  5, 10),
    (4, 1004, '2026-04-22 09:00:00', NULL,                  'open',      6, 7);

INSERT INTO chat_messages (chat_session_id, chat_message_id, sender, sent_at, content, is_received) VALUES
    (1, 1, 'customer', '2026-04-08 10:00:00', 'Hi, my card was declined when paying invoice #5. Can you help?',         true),
    (1, 2, 'staff',    '2026-04-08 10:02:00', 'Hi Eva! I can see the failed attempt. Please try again with a new card.', true),
    (1, 3, 'customer', '2026-04-08 10:20:00', 'It worked now, thank you!',                                              true),
    (1, 4, 'staff',    '2026-04-08 10:25:00', 'Great! Your payment is confirmed. Have a great day!',                    true),
    (2, 1, 'customer', '2026-04-10 14:00:00', 'Where is my parcel from order #6? It has been a few days.',              true),
    (2, 2, 'staff',    '2026-04-10 14:05:00', 'Hi Alice! Your parcel is at the depot and will be dispatched tomorrow.', true),
    (3, 1, 'customer', '2026-04-19 09:00:00', 'My parcel was not delivered yesterday. What happened?',                  true),
    (3, 2, 'staff',    '2026-04-19 09:05:00', 'Hi James! The driver attempted delivery but no one was home. Retry today.',true),
    (3, 3, 'customer', '2026-04-19 09:20:00', 'Ok thank you.',                                                          true),
    (4, 1, 'customer', '2026-04-22 09:00:00', 'Hi, I would like to know about eco delivery options.',                   false);

INSERT INTO notifications (notification_id, channel_type_id, content, sent_at, delivery_status, tracking_event_id, customer_id) VALUES
    (1,  1, 'Your parcel #1 has been picked up.',              '2026-04-01 08:35:00', 'sent',    1,  1),
    (2,  1, 'Your parcel #1 has arrived at Sydney depot.',     '2026-04-01 09:05:00', 'sent',    2,  1),
    (3,  1, 'Your parcel #1 is out for delivery.',             '2026-04-01 12:35:00', 'sent',    4,  1),
    (4,  1, 'Your parcel #1 has been delivered!',              '2026-04-01 13:50:00', 'sent',    5,  1),
    (5,  2, 'ParcelGo: Parcel #3 picked up.',                  '2026-04-01 08:35:00', 'sent',    6,  2),
    (6,  2, 'ParcelGo: Parcel #3 delivered.',                  '2026-04-01 13:05:00', 'sent',    8,  2),
    (7,  1, 'Your parcel #4 has been picked up.',              '2026-04-05 08:35:00', 'sent',    9,  3),
    (8,  1, 'Your parcel #4 has been delivered!',              '2026-04-05 10:20:00', 'sent',    13, 3),
    (9,  1, 'Your parcel #6 has been picked up.',              '2026-04-06 08:05:00', 'sent',    14, 4),
    (10, 1, 'Payment failed for invoice #5. Please retry.',  '2026-04-08 11:35:00', 'sent',    NULL, 5),
    (11, 1, 'Your parcel #11 is at Brisbane depot.',           '2026-04-10 09:05:00', 'sent',    19, 7),
    (12, 1, 'Delivery of parcel #28 failed. Retry tomorrow.','2026-04-18 09:35:00', 'sent',    27, 10),
    (13, 1, 'Your parcel #28 has been delivered!',             '2026-04-19 09:05:00', 'sent',    28, 10),
    (14, 3, 'Your order #19 has been cancelled.',              '2026-04-10 12:00:00', 'sent',    NULL, 6),
    (15, 1, 'Invoice #2 failed delivery — invalid address.', '2026-04-01 14:36:00', 'failed',  NULL, 2);

-- ══ LOG TABLES ════════════════════════════
INSERT INTO scan_alert_logs (scan_alert_id, parcel_id, depot_id, alert_type, raised_at, resolved_at, resolved_by, comments) VALUES
    (1, 10, 3, 'oversize', '2026-04-10 09:35:00', '2026-04-10 10:00:00', 3, 'Parcel exceeded standard slot — moved to oversized zone'),
    (2, 28, 5, 'damaged',  '2026-04-18 08:35:00', '2026-04-18 09:00:00', 3, 'Minor corner damage noted — customer informed');

-- ============================================================================
-- PARCELGO - Indexing Script for Optimisation (Power BI & Operations)
-- ============================================================================
-- Note: MySQL already indexes Primary Keys and Foreign Keys automatically.
-- These indexes are designed specifically to improve the complex queries, 
-- groupings, and date/status filters used in Power BI.
-- ============================================================================

USE parcelgo;

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Optimisation for Map Query (Routes and Geography)
-- ────────────────────────────────────────────────────────────────────────────

-- Improves grouping and filtering by route type and service level.
CREATE INDEX idx_routes_type_service 
    ON routes (route_type, service_type);

-- Improves location searches (important for geography Joins).
CREATE INDEX idx_addresses_postal 
    ON addresses (postal_code_id, suburb_id);

CREATE INDEX idx_postal_codes_city 
    ON postal_codes (city_id);

CREATE INDEX idx_cities_state 
    ON cities (state_id);

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Optimisation for Productivity Matrix (Assignments CTE)
-- ────────────────────────────────────────────────────────────────────────────

-- This is a "Covering Index" or Compound Index, which is very important for query #2.
-- It greatly speeds up the WHERE status = 'completed' filter and the calculation 
-- of the time difference (start_at, end_at).
CREATE INDEX idx_assignments_status_dates 
    ON assignments (status, start_at, end_at);

-- Improves the join between routes and assignments for the total count.
CREATE INDEX idx_assignments_route_status 
    ON assignments (route_id, status);

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Operational Indexes (For the general app and fast searches)
-- ────────────────────────────────────────────────────────────────────────────

-- Speeds up the search for a parcel's tracking history, ordered by date.
CREATE INDEX idx_tracking_parcel_date 
    ON tracking_events (parcel_id, created_at DESC);

-- Speeds up reports for customer order statuses on specific dates.
CREATE INDEX idx_orders_customer_status_date 
    ON orders (customer_id, status, placed_at);

-- Speeds up the search for active parcels inside an order.
CREATE INDEX idx_parcels_order_status 
    ON parcels (order_id, lifecycle_status_id);

-- Improves the search for pending or paid invoices within a period.
CREATE INDEX idx_invoices_status_date 
    ON invoices (status, invoiced_at);

-- Speeds up the count of saved emissions per assignment.
CREATE INDEX idx_emissions_assignment 
    ON emission_records (assignment_id, emissions_saved);