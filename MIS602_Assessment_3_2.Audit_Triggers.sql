-- ─────────────────────────────────────────────────────
-- PARCELGO – Audit & Log Trigger Logic
-- ─────────────────────────────────────────────────────
-- This file implements two layers of logic:
--
-- LAYER 1 – SOFT REFERENCE VALIDATION (notification_logs,
--            pay_attempt_logs, scan_alert_logs)
--   These log tables intentionally avoid hard FKs so that
--   logs are preserved even if parent records are deleted.
--   BEFORE INSERT triggers enforce referential integrity
--   at insert time without creating FK constraints.
--
-- LAYER 2 – AUDIT TRAIL (audit_records)
--   AFTER INSERT / UPDATE / DELETE triggers on core tables
--   automatically write a record to audit_records whenever
--   data changes, capturing who changed what and when.
-- ─────────────────────────────────────────────────────

USE parcelgo;

-- ══════════════════════════════════════════════════════
-- LAYER 1 — SOFT REFERENCE VALIDATION TRIGGERS
-- ══════════════════════════════════════════════════════

-- ── notification_logs ─────────────────────────────────
-- Soft refs: notification_id → notifications
--            channel_type_id → channel_types

DELIMITER //

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

-- ── pay_attempt_logs ──────────────────────────────────
-- Soft refs: invoice_id  → invoices
--            method_id   → payment_methods

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

-- ── scan_alert_logs ───────────────────────────────────
-- Soft refs: parcel_id   → parcels
--            depot_id    → depots
--            resolved_by → staff (optional, only checked if not NULL)

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
            WHEN 'sent'    THEN 'sent'
            WHEN 'failed'  THEN 'failed'
            ELSE 'failed'
        END,
        NULL
    );
END;
//

DELIMITER ;

DELIMITER //


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

DELIMITER ;

-- ══════════════════════════════════════════════════════
-- LAYER 2 — AUDIT TRAIL TRIGGERS
-- ══════════════════════════════════════════════════════
-- These triggers fire on INSERT, UPDATE, and DELETE on
-- the core business tables and write a row to audit_records.
--
-- user_type is set to 'system' as a safe default since
-- MySQL triggers do not have native session-user context.
-- In a real app, you would SET a session variable before
-- each operation, e.g.: SET @current_user_id = 42;
--                        SET @current_user_type = 'staff';
-- and reference NEW.* or @current_user_id here.
-- ──────────────────────────────────────────────────────

DELIMITER //

-- ── customers ─────────────────────────────────────────

CREATE TRIGGER trg_audit_customers_insert
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'customers', NEW.customer_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_customers_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'customers', NEW.customer_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_customers_delete
AFTER DELETE ON customers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'customers', OLD.customer_id, NOW(), 'system', 0);
END;
//

-- ── orders ────────────────────────────────────────────

CREATE TRIGGER trg_audit_orders_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'orders', NEW.order_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_orders_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'orders', NEW.order_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_orders_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'orders', OLD.order_id, NOW(), 'system', 0);
END;
//

-- ── parcels ───────────────────────────────────────────

CREATE TRIGGER trg_audit_parcels_insert
AFTER INSERT ON parcels
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'parcels', NEW.parcel_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_parcels_update
AFTER UPDATE ON parcels
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'parcels', NEW.parcel_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_parcels_delete
AFTER DELETE ON parcels
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'parcels', OLD.parcel_id, NOW(), 'system', 0);
END;
//

-- ── invoices ──────────────────────────────────────────

CREATE TRIGGER trg_audit_invoices_insert
AFTER INSERT ON invoices
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'invoices', NEW.invoice_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_invoices_update
AFTER UPDATE ON invoices
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'invoices', NEW.invoice_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_invoices_delete
AFTER DELETE ON invoices
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'invoices', OLD.invoice_id, NOW(), 'system', 0);
END;
//

-- ── payments ──────────────────────────────────────────

CREATE TRIGGER trg_audit_payments_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'payments', NEW.payment_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_payments_update
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'payments', NEW.payment_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_payments_delete
AFTER DELETE ON payments
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'payments', OLD.payment_id, NOW(), 'system', 0);
END;
//

-- ── staff ─────────────────────────────────────────────

CREATE TRIGGER trg_audit_staff_insert
AFTER INSERT ON staff
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'staff', NEW.staff_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_staff_update
AFTER UPDATE ON staff
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'staff', NEW.staff_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_staff_delete
AFTER DELETE ON staff
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'staff', OLD.staff_id, NOW(), 'system', 0);
END;
//

-- ── drivers ───────────────────────────────────────────

CREATE TRIGGER trg_audit_drivers_insert
AFTER INSERT ON drivers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'drivers', NEW.driver_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_drivers_update
AFTER UPDATE ON drivers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'drivers', NEW.driver_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_drivers_delete
AFTER DELETE ON drivers
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'drivers', OLD.driver_id, NOW(), 'system', 0);
END;
//

-- ── vehicles ──────────────────────────────────────────

CREATE TRIGGER trg_audit_vehicles_insert
AFTER INSERT ON vehicles
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('INSERT', 'vehicles', NEW.vehicle_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_vehicles_update
AFTER UPDATE ON vehicles
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('UPDATE', 'vehicles', NEW.vehicle_id, NOW(), 'system', 0);
END;
//

CREATE TRIGGER trg_audit_vehicles_delete
AFTER DELETE ON vehicles
FOR EACH ROW
BEGIN
  INSERT INTO audit_records (action, table_name, record_id, changed_at, user_type, user_id)
  VALUES ('DELETE', 'vehicles', OLD.vehicle_id, NOW(), 'system', 0);
END;
//

DELIMITER ;
