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
    (6,  'MEL Metro Delivery 2',   4,   16,  14.5, 0.60, 'express',  'delivery');

-- Original Assignments
INSERT INTO assignments (assignment_id, created_at, start_at, end_at, status, route_id, vehicle_id, driver_id) VALUES
    (1,  '2026-04-01 07:00:00', '2026-04-01 08:00:00', '2026-04-01 10:00:00', 'completed',   1,  1,  1),
    (2,  '2026-04-01 07:00:00', '2026-04-01 11:00:00', '2026-04-01 14:00:00', 'completed',   2,  1,  1),
    (3,  '2026-04-05 07:00:00', '2026-04-05 08:00:00', '2026-04-05 10:30:00', 'completed',   3,  2,  2),
    (4,  '2026-04-06 06:00:00', '2026-04-06 07:00:00', '2026-04-06 18:00:00', 'completed',   4,  3,  3);

-- Expanded Assignments (Performance bias for top performers query)
INSERT INTO assignments (assignment_id, created_at, start_at, end_at, status, route_id, vehicle_id, driver_id)
WITH RECURSIVE seq AS (SELECT 5 AS id UNION ALL SELECT id + 1 FROM seq WHERE id <= 200)
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

-- ══ BILLING & INVOICES ════════════════════════════════

-- Original Invoices
INSERT INTO invoices (invoice_id, billing_period, invoiced_at, status, total_amount, currency, billing_detail_id, discount_rule_id) VALUES
    (1,  'April 2026', '2026-04-01 14:00:00', 'paid',    20.50,  'AUD', 1,  NULL),
    (2,  'April 2026', '2026-04-01 14:00:00', 'paid',    8.50,   'AUD', 2,  NULL),
    (3,  'April 2026', '2026-04-05 11:00:00', 'paid',    24.00,  'AUD', 3,  NULL),
    (4,  'April 2026', '2026-04-06 19:00:00', 'paid',    22.00,  'AUD', 4,  NULL),
    (5,  'April 2026', '2026-04-08 11:00:00', 'paid',    28.00,  'AUD', 5,  1),
    (6,  'April 2026', '2026-04-10 15:00:00', 'issued',  36.00,  'AUD', 1,  NULL),
    (7,  'April 2026', '2026-04-10 15:00:00', 'issued',  12.00,  'AUD', 7,  NULL);

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

-- Original Payments
INSERT INTO payments (payment_id, transaction_ref, transaction_at, amount, currency, status, payment_method_id, invoice_id) VALUES
    (1,  'TXN-20260401-001', '2026-04-01 14:30:00', 20.50, 'AUD', 'completed', 1, 1),
    (2,  'TXN-20260401-002', '2026-04-01 14:35:00', 8.50,  'AUD', 'completed', 3, 2),
    (3,  'TXN-20260405-001', '2026-04-05 11:30:00', 24.00, 'AUD', 'completed', 1, 3);

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

-- ══ TRACKING EVENTS ══════════════════════════════════

-- Original Tracking Events
INSERT INTO tracking_events (tracking_event_id, created_at, notes, event_type_id, assignment_id, parcel_id, address_id, staff_id) VALUES
    (1, '2026-04-01 08:30:00', NULL, 1, 1, 1, 11, NULL),
    (2, '2026-04-01 09:00:00', NULL, 2, 1, 1, 1, 3),
    (3, '2026-04-01 09:15:00', NULL, 3, 1, 1, 1, 3),
    (4, '2026-04-01 12:30:00', NULL, 4, 2, 1, 1, 3),
    (5, '2026-04-01 13:45:00', NULL, 5, 2, 1, 11, NULL);

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