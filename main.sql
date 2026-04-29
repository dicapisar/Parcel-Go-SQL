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
