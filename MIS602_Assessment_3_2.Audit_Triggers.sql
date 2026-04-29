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

-- ── customers ─────────────────────────────────────────────────────

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

-- ── orders ────────────────────────────────────────────────────────

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

-- ── parcels ───────────────────────────────────────────────────────

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

-- ── invoices ──────────────────────────────────────────────────────

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

-- ── payments ──────────────────────────────────────────────────────

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

-- ── staff ─────────────────────────────────────────────────────────

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

-- ── drivers ───────────────────────────────────────────────────────

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

-- ── vehicles ──────────────────────────────────────────────────────

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
