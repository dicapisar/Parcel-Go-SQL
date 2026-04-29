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
