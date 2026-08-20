# DEVELOPMENT GUIDE

## 1) Local setup
1. Copy `.env.local.example` to `.env.local`.
2. Add Supabase values:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start dev server:
   ```bash
   npm run dev
   ```

## 2) Apply database migrations
Use Supabase SQL editor or migration tooling to apply files in `/migrations` in order:
1. `20260817224000_phase1_schema.sql`
2. `20260817224500_phase1_seed.sql`

## 3) Verify PHASE 1 checklist
- Foreign keys and constraints are active.
- RLS enabled and cross-business reads blocked.
- Demo users can authenticate.
- RPC functions are callable.
- Demo data appears for products, suppliers, customers, and batches.

## 4) Ready for PHASE 2
Auth pages and protected-route foundation are in place. Next phase can safely build app shell and navigation.
