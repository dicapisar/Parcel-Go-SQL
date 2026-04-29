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
