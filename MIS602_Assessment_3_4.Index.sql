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