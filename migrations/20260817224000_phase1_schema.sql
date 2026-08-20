-- PHASE 1 schema: tenancy, auth, products, ledgers, security
create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  legal_name text,
  owner_name text,
  phone text,
  email text,
  address text,
  city text,
  province text,
  country text not null default 'Pakistan',
  ntn text,
  logo_url text,
  currency text not null default 'PKR',
  timezone text not null default 'Asia/Karachi',
  language text not null default 'en',
  invoice_prefix text not null default 'INV',
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  code text not null,
  phone text,
  address text,
  city text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (business_id, code)
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  business_id uuid references public.businesses(id) on delete set null,
  branch_id uuid references public.branches(id) on delete set null,
  full_name text,
  phone text,
  avatar_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.roles (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  description text,
  created_at timestamptz not null default timezone('utc', now()),
  unique (business_id, name)
);

create table if not exists public.permissions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text
);

create table if not exists public.role_permissions (
  role_id uuid not null references public.roles(id) on delete cascade,
  permission_id uuid not null references public.permissions(id) on delete cascade,
  primary key (role_id, permission_id)
);

create table if not exists public.user_roles (
  user_id uuid not null references public.profiles(id) on delete cascade,
  role_id uuid not null references public.roles(id) on delete cascade,
  business_id uuid not null references public.businesses(id) on delete cascade,
  primary key (user_id, role_id, business_id)
);

create table if not exists public.warehouses (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  branch_id uuid references public.branches(id) on delete set null,
  name text not null,
  code text not null,
  location text,
  manager_id uuid references public.profiles(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (business_id, code)
);

create table if not exists public.product_categories (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (business_id, name)
);

create table if not exists public.product_brands (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  manufacturer text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (business_id, name)
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  category_id uuid references public.product_categories(id) on delete set null,
  brand_id uuid references public.product_brands(id) on delete set null,
  sku text not null,
  barcode text,
  name text not null,
  urdu_name text,
  product_type text,
  unit text not null default 'bag',
  pack_size numeric(12,2) not null default 0,
  purchase_price numeric(12,2) not null default 0,
  sale_price numeric(12,2) not null default 0,
  wholesale_price numeric(12,2) not null default 0,
  minimum_sale_price numeric(12,2) not null default 0,
  minimum_stock numeric(12,2) not null default 0,
  maximum_stock numeric(12,2),
  tax_rate numeric(6,2) not null default 0,
  image_url text,
  description text,
  npk_ratio text,
  nitrogen_percent numeric(6,2),
  phosphorus_percent numeric(6,2),
  potassium_percent numeric(6,2),
  zinc_percent numeric(6,2),
  sulfur_percent numeric(6,2),
  recommended_crop text,
  application_method text,
  dosage text,
  storage_instructions text,
  safety_instructions text,
  registration_number text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (business_id, sku),
  unique (business_id, barcode),
  check (pack_size >= 0),
  check (purchase_price >= 0),
  check (sale_price >= 0),
  check (wholesale_price >= 0),
  check (minimum_sale_price >= 0),
  check (minimum_stock >= 0),
  check (maximum_stock is null or maximum_stock >= 0),
  check (tax_rate >= 0)
);

create table if not exists public.product_batches (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  batch_number text not null,
  manufacturing_date date,
  expiry_date date,
  purchase_price numeric(12,2) not null,
  quantity_received numeric(12,2) not null,
  quantity_remaining numeric(12,2) not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (business_id, product_id, batch_number),
  check (purchase_price >= 0),
  check (quantity_received >= 0),
  check (quantity_remaining >= 0)
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  company text,
  phone text,
  email text,
  address text,
  city text,
  tax_number text,
  credit_limit numeric(12,2) not null default 0,
  opening_balance numeric(12,2) not null default 0,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (credit_limit >= 0)
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  phone text,
  cnic text,
  address text,
  village text,
  city text,
  farm_name text,
  farm_location text,
  land_acres numeric(12,2),
  credit_limit numeric(12,2) not null default 0,
  opening_balance numeric(12,2) not null default 0,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (credit_limit >= 0),
  check (land_acres is null or land_acres >= 0)
);

create table if not exists public.customer_transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  transaction_type text not null check (transaction_type in ('opening', 'sale', 'payment', 'sale_return', 'adjustment')),
  reference_id uuid,
  reference_number text,
  debit numeric(12,2) not null default 0,
  credit numeric(12,2) not null default 0,
  description text,
  transaction_date timestamptz not null default timezone('utc', now()),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  check (debit >= 0),
  check (credit >= 0)
);

create table if not exists public.supplier_transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  supplier_id uuid not null references public.suppliers(id) on delete cascade,
  transaction_type text not null check (transaction_type in ('opening', 'purchase', 'payment', 'purchase_return', 'adjustment')),
  reference_id uuid,
  reference_number text,
  debit numeric(12,2) not null default 0,
  credit numeric(12,2) not null default 0,
  description text,
  transaction_date timestamptz not null default timezone('utc', now()),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  check (debit >= 0),
  check (credit >= 0)
);

create table if not exists public.inventory_transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  branch_id uuid references public.branches(id) on delete set null,
  warehouse_id uuid not null references public.warehouses(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  batch_id uuid references public.product_batches(id) on delete set null,
  transaction_type text not null check (transaction_type in ('opening', 'purchase', 'sale', 'sale_return', 'purchase_return', 'adjustment', 'damage', 'expiry', 'transfer_in', 'transfer_out')),
  reference_id uuid,
  reference_number text,
  quantity_in numeric(12,2) not null default 0,
  quantity_out numeric(12,2) not null default 0,
  unit_cost numeric(12,2),
  notes text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  check (quantity_in >= 0),
  check (quantity_out >= 0),
  check (unit_cost is null or unit_cost >= 0)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null,
  title text not null,
  message text not null,
  is_read boolean not null default false,
  reference_id uuid,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete set null,
  action text not null,
  table_name text not null,
  record_id uuid,
  old_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.business_settings (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  setting_key text not null,
  setting_value jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (business_id, setting_key)
);

create index if not exists idx_businesses_name on public.businesses(name);
create index if not exists idx_branches_business_id on public.branches(business_id);
create index if not exists idx_profiles_business_id on public.profiles(business_id);
create index if not exists idx_warehouses_business_id on public.warehouses(business_id);
create index if not exists idx_product_categories_business_id on public.product_categories(business_id);
create index if not exists idx_product_brands_business_id on public.product_brands(business_id);
create index if not exists idx_products_business_id on public.products(business_id);
create index if not exists idx_products_barcode on public.products(barcode);
create index if not exists idx_products_sku on public.products(sku);
create index if not exists idx_products_name on public.products(name);
create index if not exists idx_product_batches_product_id on public.product_batches(product_id);
create index if not exists idx_product_batches_batch_number on public.product_batches(batch_number);
create index if not exists idx_product_batches_expiry_date on public.product_batches(expiry_date);
create index if not exists idx_product_batches_warehouse_id on public.product_batches(warehouse_id);
create index if not exists idx_suppliers_business_id on public.suppliers(business_id);
create index if not exists idx_customers_business_id on public.customers(business_id);
create index if not exists idx_customer_transactions_business_id on public.customer_transactions(business_id);
create index if not exists idx_supplier_transactions_business_id on public.supplier_transactions(business_id);
create index if not exists idx_inventory_transactions_business_id on public.inventory_transactions(business_id);
create index if not exists idx_inventory_transactions_product_id on public.inventory_transactions(product_id);
create index if not exists idx_notifications_business_id on public.notifications(business_id);
create index if not exists idx_notifications_user_id on public.notifications(user_id);
create index if not exists idx_audit_logs_business_id on public.audit_logs(business_id);
create index if not exists idx_business_settings_business_id on public.business_settings(business_id);

create or replace function public.get_user_business_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select p.business_id
  from public.profiles p
  where p.id = auth.uid();
$$;

create or replace function public.get_user_branch_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select p.branch_id
  from public.profiles p
  where p.id = auth.uid();
$$;

create or replace function public.get_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select r.name
  from public.user_roles ur
  join public.roles r on r.id = ur.role_id
  where ur.user_id = auth.uid()
    and ur.business_id = public.get_user_business_id()
  order by r.name
  limit 1;
$$;

create or replace function public.has_permission(permission_code text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_roles ur
    join public.role_permissions rp on rp.role_id = ur.role_id
    join public.permissions p on p.id = rp.permission_id
    where ur.user_id = auth.uid()
      and ur.business_id = public.get_user_business_id()
      and p.code = permission_code
  );
$$;

create or replace function public.prevent_ledger_changes()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Historical ledger transactions are immutable';
end;
$$;

create or replace function public.write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_business_id uuid;
begin
  v_business_id := coalesce(new.business_id, old.business_id);

  insert into public.audit_logs (business_id, user_id, action, table_name, record_id, old_data, new_data)
  values (
    v_business_id,
    auth.uid(),
    tg_op,
    tg_table_name,
    coalesce(new.id, old.id),
    case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end,
    case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end
  );

  return coalesce(new, old);
end;
$$;

create or replace function public.create_business(business_name text, owner_email text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_business_id uuid;
  v_branch_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  insert into public.businesses (name, legal_name, owner_name, email)
  values (business_name, business_name, owner_email, owner_email)
  returning id into v_business_id;

  insert into public.branches (business_id, name, code, city)
  values (v_business_id, 'Main Branch', 'MAIN', 'Karachi')
  returning id into v_branch_id;

  insert into public.profiles (id, business_id, branch_id, full_name)
  values (auth.uid(), v_business_id, v_branch_id, owner_email)
  on conflict (id) do update
    set business_id = excluded.business_id,
        branch_id = excluded.branch_id,
        full_name = excluded.full_name,
        updated_at = timezone('utc', now());

  return v_business_id;
end;
$$;

create or replace function public.adjust_stock(product_id uuid, batch_id uuid, quantity_change numeric, reason text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_batch public.product_batches%rowtype;
  v_warehouse public.warehouses%rowtype;
  v_txn_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select * into v_batch
  from public.product_batches pb
  where pb.id = batch_id
    and pb.product_id = adjust_stock.product_id
    and pb.business_id = public.get_user_business_id()
  for update;

  if not found then
    raise exception 'Batch not found for current business';
  end if;

  if (v_batch.quantity_remaining + quantity_change) < 0 then
    raise exception 'Stock cannot become negative';
  end if;

  update public.product_batches
  set quantity_remaining = quantity_remaining + quantity_change,
      updated_at = timezone('utc', now())
  where id = v_batch.id;

  select * into v_warehouse from public.warehouses where id = v_batch.warehouse_id;

  insert into public.inventory_transactions (
    business_id,
    branch_id,
    warehouse_id,
    product_id,
    batch_id,
    transaction_type,
    quantity_in,
    quantity_out,
    unit_cost,
    notes,
    created_by
  )
  values (
    v_batch.business_id,
    v_warehouse.branch_id,
    v_batch.warehouse_id,
    adjust_stock.product_id,
    v_batch.id,
    'adjustment',
    case when quantity_change > 0 then quantity_change else 0 end,
    case when quantity_change < 0 then abs(quantity_change) else 0 end,
    v_batch.purchase_price,
    reason,
    auth.uid()
  )
  returning id into v_txn_id;

  return v_txn_id;
end;
$$;

create or replace function public.record_customer_payment(sale_id uuid, amount numeric, payment_method text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_business_id uuid;
  v_customer_id uuid;
  v_txn_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if amount <= 0 then
    raise exception 'Payment amount must be positive';
  end if;

  v_business_id := public.get_user_business_id();

  select customer_id into v_customer_id
  from public.customer_transactions
  where reference_id = sale_id
    and business_id = v_business_id
    and transaction_type in ('sale', 'sale_return')
  order by created_at desc
  limit 1;

  if v_customer_id is null then
    raise exception 'Customer not found for sale reference';
  end if;

  insert into public.customer_transactions (
    business_id,
    customer_id,
    transaction_type,
    reference_id,
    reference_number,
    debit,
    credit,
    description,
    created_by
  )
  values (
    v_business_id,
    v_customer_id,
    'payment',
    sale_id,
    'PAY-' || to_char(now(), 'YYYYMMDDHH24MISS'),
    0,
    amount,
    'Customer payment via ' || payment_method,
    auth.uid()
  )
  returning id into v_txn_id;

  return v_txn_id;
end;
$$;

create or replace function public.record_supplier_payment(purchase_id uuid, amount numeric, payment_method text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_business_id uuid;
  v_supplier_id uuid;
  v_txn_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if amount <= 0 then
    raise exception 'Payment amount must be positive';
  end if;

  v_business_id := public.get_user_business_id();

  select supplier_id into v_supplier_id
  from public.supplier_transactions
  where reference_id = purchase_id
    and business_id = v_business_id
    and transaction_type in ('purchase', 'purchase_return')
  order by created_at desc
  limit 1;

  if v_supplier_id is null then
    raise exception 'Supplier not found for purchase reference';
  end if;

  insert into public.supplier_transactions (
    business_id,
    supplier_id,
    transaction_type,
    reference_id,
    reference_number,
    debit,
    credit,
    description,
    created_by
  )
  values (
    v_business_id,
    v_supplier_id,
    'payment',
    purchase_id,
    'PAY-' || to_char(now(), 'YYYYMMDDHH24MISS'),
    0,
    amount,
    'Supplier payment via ' || payment_method,
    auth.uid()
  )
  returning id into v_txn_id;

  return v_txn_id;
end;
$$;

create trigger set_businesses_updated_at before update on public.businesses for each row execute function public.set_updated_at();
create trigger set_branches_updated_at before update on public.branches for each row execute function public.set_updated_at();
create trigger set_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger set_warehouses_updated_at before update on public.warehouses for each row execute function public.set_updated_at();
create trigger set_product_categories_updated_at before update on public.product_categories for each row execute function public.set_updated_at();
create trigger set_product_brands_updated_at before update on public.product_brands for each row execute function public.set_updated_at();
create trigger set_products_updated_at before update on public.products for each row execute function public.set_updated_at();
create trigger set_product_batches_updated_at before update on public.product_batches for each row execute function public.set_updated_at();
create trigger set_suppliers_updated_at before update on public.suppliers for each row execute function public.set_updated_at();
create trigger set_customers_updated_at before update on public.customers for each row execute function public.set_updated_at();
create trigger set_business_settings_updated_at before update on public.business_settings for each row execute function public.set_updated_at();

create trigger prevent_customer_transactions_update
before update or delete on public.customer_transactions
for each row execute function public.prevent_ledger_changes();

create trigger prevent_supplier_transactions_update
before update or delete on public.supplier_transactions
for each row execute function public.prevent_ledger_changes();

create trigger audit_products_changes
after insert or update or delete on public.products
for each row execute function public.write_audit_log();
create trigger audit_product_batches_changes
after insert or update or delete on public.product_batches
for each row execute function public.write_audit_log();
create trigger audit_customers_changes
after insert or update or delete on public.customers
for each row execute function public.write_audit_log();
create trigger audit_suppliers_changes
after insert or update or delete on public.suppliers
for each row execute function public.write_audit_log();

alter table public.businesses enable row level security;
alter table public.branches enable row level security;
alter table public.profiles enable row level security;
alter table public.roles enable row level security;
alter table public.permissions enable row level security;
alter table public.role_permissions enable row level security;
alter table public.user_roles enable row level security;
alter table public.warehouses enable row level security;
alter table public.product_categories enable row level security;
alter table public.product_brands enable row level security;
alter table public.products enable row level security;
alter table public.product_batches enable row level security;
alter table public.suppliers enable row level security;
alter table public.customers enable row level security;
alter table public.customer_transactions enable row level security;
alter table public.supplier_transactions enable row level security;
alter table public.inventory_transactions enable row level security;
alter table public.notifications enable row level security;
alter table public.audit_logs enable row level security;
alter table public.business_settings enable row level security;

create policy business_isolation_businesses on public.businesses
for all to authenticated
using (id = public.get_user_business_id())
with check (id = public.get_user_business_id());

create policy business_isolation_branches on public.branches
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy profile_select_same_business on public.profiles
for select to authenticated
using (business_id = public.get_user_business_id() or id = auth.uid());
create policy profile_update_own on public.profiles
for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());
create policy profile_insert_own on public.profiles
for insert to authenticated
with check (id = auth.uid() and business_id = public.get_user_business_id());

create policy roles_same_business on public.roles
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy permissions_read_all on public.permissions
for select to authenticated
using (true);

create policy role_permissions_same_business on public.role_permissions
for all to authenticated
using (
  exists (
    select 1
    from public.roles r
    where r.id = role_id and r.business_id = public.get_user_business_id()
  )
)
with check (
  exists (
    select 1
    from public.roles r
    where r.id = role_id and r.business_id = public.get_user_business_id()
  )
);

create policy user_roles_same_business on public.user_roles
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy warehouses_business_branch_isolation on public.warehouses
for all to authenticated
using (
  business_id = public.get_user_business_id()
  and (public.get_user_branch_id() is null or branch_id is null or branch_id = public.get_user_branch_id())
)
with check (
  business_id = public.get_user_business_id()
  and (public.get_user_branch_id() is null or branch_id is null or branch_id = public.get_user_branch_id())
);

create policy product_categories_same_business on public.product_categories
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy product_brands_same_business on public.product_brands
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy products_same_business on public.products
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy product_batches_same_business on public.product_batches
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy suppliers_same_business on public.suppliers
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy customers_same_business on public.customers
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy customer_transactions_same_business on public.customer_transactions
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy supplier_transactions_same_business on public.supplier_transactions
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

create policy inventory_transactions_business_branch_isolation on public.inventory_transactions
for all to authenticated
using (
  business_id = public.get_user_business_id()
  and (public.get_user_branch_id() is null or branch_id is null or branch_id = public.get_user_branch_id())
)
with check (
  business_id = public.get_user_business_id()
  and (public.get_user_branch_id() is null or branch_id is null or branch_id = public.get_user_branch_id())
);

create policy notifications_own_business_user on public.notifications
for all to authenticated
using (business_id = public.get_user_business_id() and user_id = auth.uid())
with check (business_id = public.get_user_business_id() and user_id = auth.uid());

create policy audit_logs_read_business on public.audit_logs
for select to authenticated
using (business_id = public.get_user_business_id());
create policy audit_logs_insert_business on public.audit_logs
for insert to authenticated
with check (business_id = public.get_user_business_id() and user_id = auth.uid());

create policy business_settings_same_business on public.business_settings
for all to authenticated
using (business_id = public.get_user_business_id())
with check (business_id = public.get_user_business_id());

revoke update, delete on public.audit_logs from authenticated;
