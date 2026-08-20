# RLS POLICIES (PHASE 1)

## Helper Functions
- `get_user_business_id()` → returns active user's business UUID.
- `get_user_role()` → returns one role name for the current user in business context.
- `has_permission(permission_code TEXT)` → permission check through role mappings.
- `get_user_branch_id()` → helper for branch isolation.

## Policy Model
- RLS is enabled on all business-owned tables.
- Policies enforce `business_id = get_user_business_id()`.
- Branch-scoped tables (e.g. `warehouses`, `inventory_transactions`) also enforce branch matching when a profile has a branch.
- `permissions` is read-only for authenticated users.
- `audit_logs` is readable/insertable for same business context and update/delete is revoked from normal authenticated access.
- Ledger immutability is enforced using triggers that block update/delete on historical customer/supplier transactions.

## Expected Result
- Cross-business data access is denied.
- Branch-restricted users only see allowed branch rows.
- Permission checks are available at database level through `has_permission(...)`.
