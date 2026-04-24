-- ─────────────────────────────────────────────────────
-- PARCELGO – Sample Data
-- Coherent story: 10 customers, 20 orders, ~35 parcels
-- across 5 depots, 10 vehicles, 8 drivers, 8 staff
-- Orders progress through realistic lifecycle stages
-- ─────────────────────────────────────────────────────

USE parcelgo;

-- ══ LOOKUP TABLES ════════════════════════════════════

INSERT INTO roles (role_id, role_name) VALUES
(1, 'Operations Administrator'),
(2, 'Billing Administrator'),
(3, 'Warehouse Staff'),
(4, 'Support Agent'),
(5, 'Manager');

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
(1,  '2000', 1),
(2,  '2010', 1),
(3,  '2060', 1),
(4,  '3000', 2),
(5,  '3004', 2),
(6,  '4000', 3),
(7,  '4101', 3),
(8,  '5000', 4),
(9,  '5067', 4),
(10, '6000', 5);

INSERT INTO suburbs (suburb_id, name, postal_code_id) VALUES
(1,  'Sydney CBD',       1),
(2,  'Surry Hills',      2),
(3,  'Wollstonecraft',   3),
(4,  'Melbourne CBD',    4),
(5,  'South Yarra',      5),
(6,  'Brisbane CBD',     6),
(7,  'South Brisbane',   7),
(8,  'Adelaide CBD',     8),
(9,  'Norwood',          9),
(10, 'Perth CBD',        10);

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
-- Extra customer/delivery addresses
(11, NULL,  '12',  'Pitt Street',         NULL, NULL, 1,  1),
(12, NULL,  '9',   'Bourke Street',       NULL, NULL, 4,  4),
(13, NULL,  '33',  'Elizabeth Street',    NULL, NULL, 6,  6),
(14, NULL,  '7',   'Rundle Street',       NULL, NULL, 9,  9),
(15, NULL,  '200', 'Murray Street',       NULL, NULL, 10, 10),
(16, NULL,  '3',   'Flinders Lane',       NULL, NULL, 5,  5),
(17, NULL,  '66',  'Ann Street',          NULL, NULL, 7,  7),
(18, NULL,  '41',  'Hindley Street',      NULL, NULL, 8,  8),
(19, NULL,  '50',  'Oxford Street',       NULL, NULL, 2,  2),
(20, NULL,  '18',  'Pacific Highway',     NULL, NULL, 3,  3);

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

INSERT INTO staff_credentials (staff_credentials_id, user_name, password, mfa, last_login, last_password_change) VALUES
(1,  'ops.admin',     '$2b$12$hashedpw1', true,  '2026-04-20 08:00:00', '2026-01-10 09:00:00'),
(2,  'billing.admin', '$2b$12$hashedpw2', true,  '2026-04-21 08:30:00', '2026-01-15 09:00:00'),
(3,  'warehouse.syd', '$2b$12$hashedpw3', false, '2026-04-22 07:00:00', '2026-02-01 09:00:00'),
(4,  'warehouse.mel', '$2b$12$hashedpw4', false, '2026-04-22 07:15:00', '2026-02-01 09:00:00'),
(5,  'support.one',   '$2b$12$hashedpw5', false, '2026-04-21 09:00:00', '2026-02-15 09:00:00'),
(6,  'support.two',   '$2b$12$hashedpw6', false, '2026-04-20 09:00:00', '2026-02-15 09:00:00'),
(7,  'manager.ops',   '$2b$12$hashedpw7', true,  '2026-04-22 08:00:00', '2026-01-05 09:00:00'),
(8,  'warehouse.bne', '$2b$12$hashedpw8', false, '2026-04-22 06:45:00', '2026-02-01 09:00:00'),
-- Driver credentials
(9,  'driver.jack',   '$2b$12$hashedpw9', false, '2026-04-22 06:00:00', '2026-01-20 09:00:00'),
(10, 'driver.sarah',  '$2b$12$hashedpw10',false, '2026-04-22 06:10:00', '2026-01-20 09:00:00'),
(11, 'driver.mike',   '$2b$12$hashedpw11',false, '2026-04-21 06:00:00', '2026-01-20 09:00:00'),
(12, 'driver.lisa',   '$2b$12$hashedpw12',false, '2026-04-22 06:20:00', '2026-01-20 09:00:00'),
(13, 'driver.tom',    '$2b$12$hashedpw13',false, '2026-04-20 06:00:00', '2026-01-20 09:00:00'),
(14, 'driver.emma',   '$2b$12$hashedpw14',false, '2026-04-22 06:30:00', '2026-01-20 09:00:00'),
(15, 'driver.james',  '$2b$12$hashedpw15',false, '2026-04-21 06:15:00', '2026-01-20 09:00:00'),
(16, 'driver.olivia', '$2b$12$hashedpw16',false, '2026-04-22 06:45:00', '2026-01-20 09:00:00');

INSERT INTO roles (role_id, role_name) VALUES (6, 'Driver') ON DUPLICATE KEY UPDATE role_name = role_name;

INSERT INTO staff (staff_id, first_name, last_name, mobile_phone, work_phone, email, manager_id, role_id, staff_credentials_id) VALUES
(1, 'David',   'Nguyen',   '0411001001', '0281001100', 'david.nguyen@parcelgo.com.au',   NULL, 5, 1),
(2, 'Rachel',  'Thompson', '0411001002', '0281001101', 'rachel.thompson@parcelgo.com.au', 1,   2, 2),
(3, 'Ben',     'Walsh',    '0411001003', '0281001102', 'ben.walsh@parcelgo.com.au',       1,   3, 3),
(4, 'Maria',   'Costa',    '0411001004', '0381001103', 'maria.costa@parcelgo.com.au',     1,   3, 4),
(5, 'Simon',   'Park',     '0411001005', '0281001104', 'simon.park@parcelgo.com.au',      1,   4, 5),
(6, 'Priya',   'Sharma',   '0411001006', '0281001105', 'priya.sharma@parcelgo.com.au',    1,   4, 6),
(7, 'Nathan',  'Ellis',    '0411001007', '0281001106', 'nathan.ellis@parcelgo.com.au',    NULL,5, 7),
(8, 'Claire',  'Hudson',   '0411001008', '0781001107', 'claire.hudson@parcelgo.com.au',   1,   3, 8);

-- ══ DRIVERS ══════════════════════════════════════════

INSERT INTO drivers (driver_id, first_name, last_name, mobile_phone, email, staff_credentials_id) VALUES
(1, 'Jack',   'Morrison',  '0421001001', 'jack.morrison@parcelgo.com.au',  9),
(2, 'Sarah',  'Brennan',   '0421001002', 'sarah.brennan@parcelgo.com.au',  10),
(3, 'Mike',   'Tran',      '0421001003', 'mike.tran@parcelgo.com.au',      11),
(4, 'Lisa',   'Patel',     '0421001004', 'lisa.patel@parcelgo.com.au',     12),
(5, 'Tom',    'Garcia',    '0421001005', 'tom.garcia@parcelgo.com.au',     13),
(6, 'Emma',   'Wilson',    '0421001006', 'emma.wilson@parcelgo.com.au',    14),
(7, 'James',  'Okafor',    '0421001007', 'james.okafor@parcelgo.com.au',   15),
(8, 'Olivia', 'Chen',      '0421001008', 'olivia.chen@parcelgo.com.au',    16);

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
(1, 'CERT-SAFE-001', 'Safe Driver Certificate',       '2024-01-15', '2027-01-15', 1),
(2, 'CERT-SAFE-002', 'Safe Driver Certificate',       '2024-02-10', '2027-02-10', 2),
(3, 'CERT-HEAVY-001','Heavy Vehicle Certification',   '2023-06-01', '2026-06-01', 3),
(4, 'CERT-SAFE-003', 'Safe Driver Certificate',       '2024-03-20', '2027-03-20', 4),
(5, 'CERT-HEAVY-002','Heavy Vehicle Certification',   '2023-09-15', '2026-09-15', 5),
(6, 'CERT-SAFE-004', 'Safe Driver Certificate',       '2025-01-10', '2028-01-10', 6),
(7, 'CERT-SAFE-005', 'Safe Driver Certificate',       '2024-07-07', '2027-07-07', 7),
(8, 'CERT-HEAVY-003','Heavy Vehicle Certification',   '2024-04-01', '2027-04-01', 8);

-- ══ VEHICLES ═════════════════════════════════════════

INSERT INTO vehicle_types (vehicle_type_id, type_name, license_required) VALUES
(1, 'Van',         'Car'),
(2, 'Truck',       'Heavy'),
(3, 'Motorcycle',  'Car'),
(4, 'Electric Van','Car');

INSERT INTO vehicles (vehicle_id, registration, capacity, is_available, vehicle_type_id) VALUES
(1,  'NSW-ABC-001', 800.00,  true,  1),
(2,  'NSW-ABC-002', 800.00,  true,  1),
(3,  'NSW-ABC-003', 2000.00, true,  2),
(4,  'VIC-XYZ-001', 800.00,  true,  1),
(5,  'VIC-XYZ-002', 2000.00, false, 2),
(6,  'QLD-DEF-001', 800.00,  true,  1),
(7,  'QLD-DEF-002', 300.00,  true,  3),
(8,  'SA-GHI-001',  800.00,  true,  4),
(9,  'WA-JKL-001',  800.00,  true,  1),
(10, 'NSW-ABC-004', 800.00,  true,  4);

INSERT INTO vehicle_maintenances (v_maintenance_id, maintenance_date, maintenance_type, notes, status, vehicle_id, recorded_by) VALUES
(1, '2026-03-10', 'routine',    'Regular 10,000km service',     'completed',  1, 1),
(2, '2026-02-20', 'repair',     'Brake pad replacement',        'completed',  3, 1),
(3, '2026-04-15', 'inspection', 'Annual roadworthy inspection',  'completed',  5, 7),
(4, '2026-04-20', 'repair',     'Engine fault — out of service','in_progress', 5, 7),
(5, '2026-03-25', 'routine',    'Regular 10,000km service',     'completed',  8, 1);

-- ══ CUSTOMERS & CREDENTIALS ══════════════════════════

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

-- Insert customers without billing_details_id first (set later)
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

INSERT INTO customer_addresses (customer_id, address_id, label, is_default) VALUES
(1,  11, 'Home',   true),
(1,  2,  'Work',   false),
(2,  12, 'Home',   true),
(3,  13, 'Home',   true),
(4,  14, 'Home',   true),
(4,  9,  'Work',   false),
(5,  15, 'Home',   true),
(6,  16, 'Home',   true),
(7,  17, 'Home',   true),
(8,  18, 'Home',   true),
(9,  19, 'Home',   true),
(9,  2,  'Work',   false),
(10, 20, 'Home',   true),
(10, 3,  'Office', false);

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

-- Now set the default billing_details_id on each customer
UPDATE customers SET billing_details_id = 1  WHERE customer_id = 1;
UPDATE customers SET billing_details_id = 2  WHERE customer_id = 2;
UPDATE customers SET billing_details_id = 3  WHERE customer_id = 3;
UPDATE customers SET billing_details_id = 4  WHERE customer_id = 4;
UPDATE customers SET billing_details_id = 5  WHERE customer_id = 5;
UPDATE customers SET billing_details_id = 6  WHERE customer_id = 6;
UPDATE customers SET billing_details_id = 7  WHERE customer_id = 7;
UPDATE customers SET billing_details_id = 8  WHERE customer_id = 8;
UPDATE customers SET billing_details_id = 9  WHERE customer_id = 9;
UPDATE customers SET billing_details_id = 10 WHERE customer_id = 10;

-- ══ FLEET: ROUTES & ASSIGNMENTS ══════════════════════

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

-- ══ ORDERS & PARCELS ═════════════════════════════════
-- Story:
-- Orders 1-5: Fully delivered (complete lifecycle)
-- Orders 6-10: In transit / at depot
-- Orders 11-15: Picked up or booked
-- Orders 16-18: Just placed / draft
-- Order 19: Cancelled
-- Order 20: Delivered but with a failed first attempt

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

INSERT INTO parcels (parcel_id, weight, height, width, length, notes, lifecycle_status_id, parcel_category_id, pickup_add_id, delivery_add_id, order_id) VALUES
-- Order 1 (delivered, 2 parcels)
(1,  2.00, 30.0, 20.0, 15.0, NULL,                      6, 1, 11, 11, 1),
(2,  1.50, 20.0, 15.0, 10.0, 'Handle with care',        2, 2, 11, 2,  1),
-- Order 2 (delivered, 1 parcel)
(3,  1.20, 25.0, 18.0, 12.0, NULL,                      6, 5, 12, 12, 2),
-- Order 3 (delivered, 2 parcels)
(4,  3.00, 40.0, 30.0, 20.0, NULL,                      6, 1, 13, 13, 3),
(5,  2.80, 35.0, 25.0, 18.0, 'Fragile — glass',         6, 2, 13, 2,  3),
-- Order 4 (delivered, 1 parcel — inter-state)
(6,  2.10, 28.0, 22.0, 16.0, NULL,                      6, 1, 14, 12, 4),
-- Order 5 (delivered, 2 parcels)
(7,  2.50, 32.0, 24.0, 18.0, NULL,                      6, 1, 15, 16, 5),
(8,  1.50, 22.0, 16.0, 12.0, NULL,                      6, 1, 15, 5,  5),
-- Order 6 (in transit, 2 parcels)
(9,  4.00, 45.0, 35.0, 25.0, NULL,                      4, 1, 11, 11, 6),
(10, 3.50, 40.0, 30.0, 22.0, 'Do not stack',            4, 4, 11, 11, 6),
-- Order 7 (in transit, 1 parcel)
(11, 1.80, 26.0, 20.0, 14.0, NULL,                      4, 1, 17, 13, 7),
-- Order 8 (in transit eco, 2 parcels)
(12, 1.80, 24.0, 18.0, 13.0, 'Eco delivery',            4, 1, 18, 17, 8),
(13, 1.40, 20.0, 15.0, 11.0, NULL,                      4, 1, 18, 7,  8),
-- Order 9 (in transit, 2 parcels)
(14, 3.50, 38.0, 28.0, 20.0, NULL,                      4, 1, 19, 14, 9),
(15, 2.50, 30.0, 22.0, 16.0, NULL,                      5, 1, 19, 9,  9),
-- Order 10 (in transit, 1 parcel)
(16, 2.50, 30.0, 22.0, 16.0, NULL,                      4, 1, 20, 15, 10),
-- Order 11 (confirmed, 1 parcel)
(17, 1.50, 22.0, 18.0, 14.0, NULL,                      2, 1, 12, 19, 11),
-- Order 12 (confirmed, 2 parcels)
(18, 2.50, 30.0, 22.0, 16.0, NULL,                      2, 2, 13, 11, 12),
(19, 2.00, 28.0, 20.0, 15.0, 'Glass — fragile',         2, 2, 13, 2,  12),
-- Order 13 (confirmed, 1 parcel — document)
(20, 0.80, 30.0, 22.0, 1.0,  'Contract documents',      2, 5, 14, 12, 13),
-- Order 14 (confirmed, 1 parcel)
(21, 3.00, 35.0, 25.0, 20.0, NULL,                      2, 1, 15, 17, 14),
-- Order 15 (confirmed, 1 parcel)
(22, 2.20, 28.0, 22.0, 16.0, NULL,                      2, 1, 16, 16, 15),
-- Order 16 (draft, 1 parcel)
(23, 1.10, 20.0, 15.0, 10.0, NULL,                      1, 1, 17, 13, 16),
-- Order 17 (draft, 2 parcels)
(24, 3.00, 35.0, 25.0, 20.0, NULL,                      1, 1, 18, 12, 17),
(25, 2.50, 30.0, 22.0, 16.0, 'Perishable — keep cool',  1, 3, 18, 4,  17),
-- Order 18 (draft, 1 parcel)
(26, 0.60, 32.0, 22.0, 1.0,  'Urgent contract',         1, 5, 19, 20, 18),
-- Order 19 (cancelled, 1 parcel)
(27, 2.80, 30.0, 22.0, 18.0, 'Cancelled by customer',   7, 1, 16, 12, 19),
-- Order 20 (delivered after retry, 2 parcels)
(28, 1.80, 26.0, 20.0, 14.0, 'Retry successful',        6, 1, 20, 15, 20),
(29, 1.30, 22.0, 16.0, 12.0, NULL,                      6, 1, 20, 15, 20);

-- ══ ASSIGNMENT_PARCELS ════════════════════════════════

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
-- staff_id logic:
--   Picked Up (event 1)  → NULL (driver collects, no depot staff)
--   Depot Arrival (2)    → warehouse staff at that depot
--   In Storage (3)       → same warehouse staff
--   Dispatched (4)       → same warehouse staff
--   Delivered (5)        → NULL (driver delivers, no depot staff)
--   Delivery Failed (6)  → NULL (driver event)
--
-- staff 3 = Ben Walsh   (Warehouse, Sydney / Adelaide coverage)
-- staff 4 = Maria Costa (Warehouse, Melbourne)
-- staff 8 = Claire Hudson (Warehouse, Brisbane)

INSERT INTO tracking_events (tracking_event_id, created_at, notes, event_type_id, assignment_id, parcel_id, address_id, staff_id) VALUES
-- Delivered parcels (full lifecycle)
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
-- In-transit parcels
(18, '2026-04-10 08:30:00', NULL, 1, 7, 11, 17, NULL),
(19, '2026-04-10 09:00:00', NULL, 2, 7, 11, 6, 8),
(20, '2026-04-10 09:15:00', NULL, 3, 7, 11, 6, 8),
(21, '2026-04-10 11:30:00', NULL, 4, 8, 9, 6, 8),
(22, '2026-04-12 08:30:00', NULL, 1, 9, 12, 18, NULL),
(23, '2026-04-12 09:00:00', NULL, 2, 9, 12, 3, 3),
(24, '2026-04-15 08:30:00', NULL, 1, 10, 14, 19, NULL),
(25, '2026-04-15 09:00:00', NULL, 2, 10, 14, 8, 3),
-- Order 20: failed first attempt then delivered
(26, '2026-04-18 08:30:00', NULL, 1, 11, 28, 20, NULL),
(27, '2026-04-18 09:30:00', 'No one home — retry tomorrow', 6, 11, 28, 15, NULL),
(28, '2026-04-19 09:00:00', NULL, 5, 11, 28, 15, NULL);
-- ══ PARCEL SLOT ASSIGNMENTS ═══════════════════════════

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

-- ══ SUSTAINABILITY ════════════════════════════════════

INSERT INTO gp_accounts (gp_account_id, gp_balance, customer_id) VALUES
(1,  125.00, 1),
(2,  40.00,  2),
(3,  0.00,   3),
(4,  80.00,  4),
(5,  200.00, 5),
(6,  0.00,   6),
(7,  55.00,  7),
(8,  30.00,  8),
(9,  90.00,  9),
(10, 110.00, 10);

INSERT INTO emission_records (emission_record_id, emission_amount, baseline, emissions_saved, assignment_id) VALUES
(1,  2.40, 3.20, 0.80, 1),
(2,  1.80, 3.20, 1.40, 2),
(3,  3.50, 4.50, 1.00, 3),
(4,  8.20, 9.00, 0.80, 4),
(5,  2.10, 3.00, 0.90, 5),
(6,  1.90, 2.80, 0.90, 6),
(7,  1.50, 2.20, 0.70, 7),
(8,  2.80, 3.50, 0.70, 8),
(9,  1.20, 2.50, 1.30, 9),
(10, 2.60, 3.40, 0.80, 10),
(11, 2.20, 3.10, 0.90, 11),
(12, 1.90, 2.80, 0.90, 12);

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

INSERT INTO invoice_lines (invoice_id, line_id, description, quantity, unit_price, line_amount, discount_rule_id, rate_id, parcel_id) VALUES
(1,  1, 'Standard Metro delivery – 2kg',   1, 8.50,  8.50,  NULL, 1,  1),
(1,  2, 'Standard Metro delivery – 1.5kg', 1, 12.00, 12.00, NULL, 2,  2),
(2,  1, 'Standard Metro delivery – 1.2kg', 1, 8.50,  8.50,  NULL, 1,  3),
(3,  1, 'Standard Metro delivery – 3kg',   1, 12.00, 12.00, NULL, 2,  4),
(3,  2, 'Standard Metro delivery – 2.8kg', 1, 12.00, 12.00, NULL, 2,  5),
(4,  1, 'Inter-state delivery – 2.1kg',    1, 22.00, 22.00, NULL, 10, 6),
(5,  1, 'Express Metro delivery – 2.5kg',  1, 14.00, 14.00, 1,   4,  7),
(5,  2, 'Express Metro delivery – 1.5kg',  1, 14.00, 14.00, 1,   4,  8),
(6,  1, 'Standard Metro delivery – 4kg',   1, 18.00, 18.00, NULL, 3,  9),
(6,  2, 'Standard Metro delivery – 3.5kg', 1, 18.00, 18.00, NULL, 3,  10),
(7,  1, 'Standard Metro delivery – 1.8kg', 1, 12.00, 12.00, NULL, 2,  11),
(8,  1, 'Eco Metro delivery – 1.8kg',      1, 7.00,  7.00,  NULL, 13, 12),
(8,  2, 'Eco Metro delivery – 1.4kg',      1, 7.00,  7.00,  NULL, 13, 13),
(9,  1, 'Standard Regional – 3.5kg',       1, 16.00, 16.00, 2,   7,  14),
(9,  2, 'Standard Regional – 2.5kg',       1, 16.00, 16.00, 2,   7,  15),
(10, 1, 'Standard Metro delivery – 2.5kg', 1, 12.00, 12.00, NULL, 2,  16),
(11, 1, 'Standard Metro delivery – 1.5kg', 1, 12.00, 12.00, NULL, 2,  17),
(12, 1, 'Standard Metro delivery – 2.5kg', 1, 12.00, 12.00, NULL, 2,  18),
(12, 2, 'Standard Metro delivery – 2kg',   1, 14.00, 14.00, NULL, 4,  19),
(13, 1, 'Document delivery – 0.8kg',       1, 8.50,  8.50,  NULL, 1,  20),
(14, 1, 'Standard Metro delivery – 3kg',   1, 18.00, 18.00, NULL, 3,  21),
(15, 1, 'Standard Metro delivery – 2.2kg', 1, 11.00, 11.00, NULL, 6,  22),
(16, 1, 'Standard Metro delivery – 1.8kg', 1, 12.00, 12.00, NULL, 2,  28),
(16, 2, 'Standard Metro delivery – 1.3kg', 1, 12.00, 12.00, NULL, 2,  29);

INSERT INTO payments (payment_id, transaction_ref, transaction_at, amount, currency, status, failure_reason, payment_method_id, invoice_id) VALUES
(1,  'TXN-20260401-001', '2026-04-01 14:30:00', 20.50, 'AUD', 'completed', NULL,                   1, 1),
(2,  'TXN-20260401-002', '2026-04-01 14:35:00', 8.50,  'AUD', 'completed', NULL,                   3, 2),
(3,  'TXN-20260405-001', '2026-04-05 11:30:00', 24.00, 'AUD', 'completed', NULL,                   1, 3),
(4,  'TXN-20260406-001', '2026-04-06 19:30:00', 22.00, 'AUD', 'completed', NULL,                   2, 4),
(5,  'TXN-20260408-001', '2026-04-08 11:30:00', 14.00, 'AUD', 'failed',    'Card declined',        1, 5),
(6,  'TXN-20260408-002', '2026-04-08 11:45:00', 28.00, 'AUD', 'completed', NULL,                   1, 5),
(7,  'TXN-20260418-001', '2026-04-18 13:00:00', 12.00, 'AUD', 'failed',    'Insufficient funds',   3, 16),
(8,  'TXN-20260418-002', '2026-04-18 13:30:00', 24.00, 'AUD', 'completed', NULL,                   3, 16);

INSERT INTO refunds (payment_id, refund_id, refunded_at, amount, reason, status, payment_method_id) VALUES
(3, 1, '2026-04-07 10:00:00', 12.00, 'Partial refund — one parcel returned', 'processed', 1);

-- ══ COMMUNICATIONS ════════════════════════════════════

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
(1,  1, 'Your parcel #1 has been picked up.',             '2026-04-01 08:35:00', 'sent',    1,  1),
(2,  1, 'Your parcel #1 has arrived at Sydney depot.',    '2026-04-01 09:05:00', 'sent',    2,  1),
(3,  1, 'Your parcel #1 is out for delivery.',            '2026-04-01 12:35:00', 'sent',    4,  1),
(4,  1, 'Your parcel #1 has been delivered!',             '2026-04-01 13:50:00', 'sent',    5,  1),
(5,  2, 'ParcelGo: Parcel #3 picked up.',                 '2026-04-01 08:35:00', 'sent',    6,  2),
(6,  2, 'ParcelGo: Parcel #3 delivered.',                 '2026-04-01 13:05:00', 'sent',    8,  2),
(7,  1, 'Your parcel #4 has been picked up.',             '2026-04-05 08:35:00', 'sent',    9,  3),
(8,  1, 'Your parcel #4 has been delivered!',             '2026-04-05 10:20:00', 'sent',    13, 3),
(9,  1, 'Your parcel #6 has been picked up.',             '2026-04-06 08:05:00', 'sent',    14, 4),
(10, 1, 'Payment failed for invoice #5. Please retry.',  '2026-04-08 11:35:00', 'sent',    NULL, 5),
(11, 1, 'Your parcel #11 is at Brisbane depot.',          '2026-04-10 09:05:00', 'sent',    19, 7),
(12, 1, 'Delivery of parcel #28 failed. Retry tomorrow.','2026-04-18 09:35:00', 'sent',    27, 10),
(13, 1, 'Your parcel #28 has been delivered!',            '2026-04-19 09:05:00', 'sent',    28, 10),
(14, 3, 'Your order #19 has been cancelled.',             '2026-04-10 12:00:00', 'sent',    NULL, 6),
(15, 1, 'Invoice #2 failed delivery — invalid address.', '2026-04-01 14:36:00', 'failed',  NULL, 2);

-- ══ LOG TABLES (tests soft-ref triggers) ══════════════

INSERT INTO scan_alert_logs (scan_alert_id, parcel_id, depot_id, alert_type, raised_at, resolved_at, resolved_by, comments) VALUES
(1, 10, 3, 'oversize', '2026-04-10 09:35:00', '2026-04-10 10:00:00', 3, 'Parcel exceeded standard slot — moved to oversized zone'),
(2, 28, 5, 'damaged',  '2026-04-18 08:35:00', '2026-04-18 09:00:00', 3, 'Minor corner damage noted — customer informed');
