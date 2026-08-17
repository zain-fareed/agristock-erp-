# DATABASE SCHEMA (PHASE 1)

## Core Domains
- **Tenancy/Auth:** `businesses`, `branches`, `profiles`, `roles`, `permissions`, `role_permissions`, `user_roles`, `warehouses`
- **Products:** `product_categories`, `product_brands`, `products`, `product_batches`
- **Partners:** `suppliers`, `customers`
- **Ledgers:** `customer_transactions`, `supplier_transactions`, `inventory_transactions`
- **System:** `notifications`, `audit_logs`, `business_settings`

## Relationship Summary
- `businesses` is the tenancy root.
- Most business data carries `business_id` for RLS isolation.
- `profiles.id` references `auth.users.id`.
- `branches`, `warehouses`, `products`, `suppliers`, `customers`, and ledgers are linked to a business.
- `roles` are business-scoped; `permissions` are global and mapped through `role_permissions` and `user_roles`.
- `product_batches` link products to warehouses with batch-level quantities and expiry.

## Constraints and Indexes
- UUID primary keys across all tables.
- TIMESTAMPTZ used for timestamps.
- Business-scoped uniqueness for SKU/barcode and branch/warehouse codes.
- Quantity/price checks prevent negative financial or stock values.
- Optimized indexes for `barcode`, `sku`, `name`, `business_id`, `batch_number`, `expiry_date`, and transactional lookups.
