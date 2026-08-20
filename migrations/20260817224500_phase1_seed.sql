-- PHASE 1 demo seed data
-- Demo credentials (development only):
-- admin@agristock.demo / Demo@123
-- manager@agristock.demo / Demo@123
-- cashier@agristock.demo / Demo@123
-- storekeeper@agristock.demo / Demo@123

with demo_business as (
  insert into public.businesses (
    id,
    name,
    legal_name,
    owner_name,
    phone,
    email,
    address,
    city,
    province,
    ntn
  )
  values (
    '11111111-1111-1111-1111-111111111111',
    'AgriStock Demo',
    'AgriStock Demo (Pvt) Ltd',
    'Demo Owner',
    '+92-300-1111111',
    'admin@agristock.demo',
    'Shahrah-e-Faisal',
    'Karachi',
    'Sindh',
    'DEMO-NTN-001'
  )
  on conflict (id) do nothing
  returning id
)
select coalesce((select id from demo_business), '11111111-1111-1111-1111-111111111111'::uuid);

insert into public.branches (id, business_id, name, code, city)
values
  ('21111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Main Branch', 'MAIN', 'Karachi'),
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Branch A', 'BRA', 'Hyderabad'),
  ('23333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Branch B', 'BRB', 'Multan')
on conflict (business_id, code) do nothing;

insert into auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
)
values
  ('a1111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin@agristock.demo', crypt('Demo@123', gen_salt('bf')), timezone('utc', now()), '{"provider":"email","providers":["email"]}', '{}', timezone('utc', now()), timezone('utc', now()), '', '', '', ''),
  ('b2222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'manager@agristock.demo', crypt('Demo@123', gen_salt('bf')), timezone('utc', now()), '{"provider":"email","providers":["email"]}', '{}', timezone('utc', now()), timezone('utc', now()), '', '', '', ''),
  ('c3333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'cashier@agristock.demo', crypt('Demo@123', gen_salt('bf')), timezone('utc', now()), '{"provider":"email","providers":["email"]}', '{}', timezone('utc', now()), timezone('utc', now()), '', '', '', ''),
  ('d4444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'storekeeper@agristock.demo', crypt('Demo@123', gen_salt('bf')), timezone('utc', now()), '{"provider":"email","providers":["email"]}', '{}', timezone('utc', now()), timezone('utc', now()), '', '', '', '')
on conflict (id) do nothing;

insert into auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  provider_id,
  created_at,
  updated_at,
  last_sign_in_at
)
values
  ('e1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', '{"sub":"a1111111-1111-1111-1111-111111111111","email":"admin@agristock.demo"}', 'email', 'admin@agristock.demo', timezone('utc', now()), timezone('utc', now()), timezone('utc', now())),
  ('e2222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', '{"sub":"b2222222-2222-2222-2222-222222222222","email":"manager@agristock.demo"}', 'email', 'manager@agristock.demo', timezone('utc', now()), timezone('utc', now()), timezone('utc', now())),
  ('e3333333-3333-3333-3333-333333333333', 'c3333333-3333-3333-3333-333333333333', '{"sub":"c3333333-3333-3333-3333-333333333333","email":"cashier@agristock.demo"}', 'email', 'cashier@agristock.demo', timezone('utc', now()), timezone('utc', now()), timezone('utc', now())),
  ('e4444444-4444-4444-4444-444444444444', 'd4444444-4444-4444-4444-444444444444', '{"sub":"d4444444-4444-4444-4444-444444444444","email":"storekeeper@agristock.demo"}', 'email', 'storekeeper@agristock.demo', timezone('utc', now()), timezone('utc', now()), timezone('utc', now()))
on conflict (id) do nothing;

insert into public.profiles (id, business_id, branch_id, full_name, phone)
values
  ('a1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', '21111111-1111-1111-1111-111111111111', 'Admin User', '+92-300-1110001'),
  ('b2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '21111111-1111-1111-1111-111111111111', 'Manager User', '+92-300-1110002'),
  ('c3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Cashier User', '+92-300-1110003'),
  ('d4444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', '23333333-3333-3333-3333-333333333333', 'Storekeeper User', '+92-300-1110004')
on conflict (id) do update
set business_id = excluded.business_id,
    branch_id = excluded.branch_id,
    full_name = excluded.full_name,
    phone = excluded.phone,
    updated_at = timezone('utc', now());

insert into public.permissions (code, name, description)
values
  ('dashboard.view', 'View Dashboard', 'Can view business dashboard metrics'),
  ('products.manage', 'Manage Products', 'Can create and update products and batches'),
  ('inventory.adjust', 'Adjust Inventory', 'Can run stock adjustments'),
  ('sales.manage', 'Manage Sales', 'Can perform sales operations'),
  ('purchases.manage', 'Manage Purchases', 'Can perform purchase operations'),
  ('payments.manage', 'Manage Payments', 'Can record supplier and customer payments'),
  ('users.manage', 'Manage Users', 'Can manage user roles and access')
on conflict (code) do nothing;

insert into public.roles (id, business_id, name, description)
values
  ('31111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'admin', 'Full access DEMO role'),
  ('32222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'manager', 'Management DEMO role'),
  ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'cashier', 'Cash counter DEMO role'),
  ('34444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'storekeeper', 'Warehouse DEMO role')
on conflict (business_id, name) do nothing;

insert into public.role_permissions (role_id, permission_id)
select '31111111-1111-1111-1111-111111111111', id from public.permissions
on conflict do nothing;

insert into public.role_permissions (role_id, permission_id)
select '32222222-2222-2222-2222-222222222222', id from public.permissions where code <> 'users.manage'
on conflict do nothing;

insert into public.role_permissions (role_id, permission_id)
select '33333333-3333-3333-3333-333333333333', id from public.permissions where code in ('dashboard.view', 'sales.manage', 'payments.manage')
on conflict do nothing;

insert into public.role_permissions (role_id, permission_id)
select '34444444-4444-4444-4444-444444444444', id from public.permissions where code in ('dashboard.view', 'products.manage', 'inventory.adjust')
on conflict do nothing;

insert into public.user_roles (user_id, role_id, business_id)
values
  ('a1111111-1111-1111-1111-111111111111', '31111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111'),
  ('b2222222-2222-2222-2222-222222222222', '32222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111'),
  ('c3333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111'),
  ('d4444444-4444-4444-4444-444444444444', '34444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111')
on conflict do nothing;

insert into public.warehouses (id, business_id, branch_id, name, code, location, manager_id)
values
  ('41111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', '21111111-1111-1111-1111-111111111111', 'Main Warehouse', 'WH-MAIN', 'Karachi Industrial Area', 'd4444444-4444-4444-4444-444444444444'),
  ('42222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Branch A Warehouse', 'WH-BRA', 'Hyderabad Link Road', 'd4444444-4444-4444-4444-444444444444'),
  ('43333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '23333333-3333-3333-3333-333333333333', 'Branch B Warehouse', 'WH-BRB', 'Multan Bypass', 'd4444444-4444-4444-4444-444444444444')
on conflict (business_id, code) do nothing;

insert into public.product_categories (id, business_id, name, description)
values
  ('51111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Urea', 'DEMO category for nitrogen fertilizer'),
  ('52222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'DAP', 'DEMO category for diammonium phosphate'),
  ('53333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'NPK', 'DEMO category for compound fertilizers'),
  ('54444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'SOP', 'DEMO category for sulfate of potash'),
  ('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'Micronutrients', 'DEMO category for micronutrient blends')
on conflict (business_id, name) do nothing;

insert into public.product_brands (business_id, name, manufacturer)
values
  ('11111111-1111-1111-1111-111111111111', 'Engro', 'Engro Fertilizers Limited'),
  ('11111111-1111-1111-1111-111111111111', 'FFC', 'Fauji Fertilizer Company Limited'),
  ('11111111-1111-1111-1111-111111111111', 'Fatima', 'Fatima Fertilizer Company Limited'),
  ('11111111-1111-1111-1111-111111111111', 'Sitara', 'Sitara Chemicals Industries Limited')
on conflict (business_id, name) do nothing;

insert into public.products (
  business_id, category_id, brand_id, sku, barcode, name, urdu_name, product_type, unit, pack_size,
  purchase_price, sale_price, wholesale_price, minimum_sale_price, minimum_stock, tax_rate,
  description, npk_ratio, nitrogen_percent, phosphorus_percent, potassium_percent,
  zinc_percent, sulfur_percent, recommended_crop, application_method, dosage,
  storage_instructions, safety_instructions, registration_number
)
select
  '11111111-1111-1111-1111-111111111111',
  c.id,
  b.id,
  p.sku,
  p.barcode,
  p.name,
  p.urdu_name,
  p.product_type,
  'bag',
  50,
  p.purchase_price,
  p.sale_price,
  p.wholesale_price,
  p.minimum_sale_price,
  20,
  0,
  p.description,
  p.npk_ratio,
  p.n_percent,
  p.p_percent,
  p.k_percent,
  p.zn_percent,
  p.s_percent,
  p.crop,
  'Broadcast',
  '1 bag per acre',
  'Store in a dry, covered area. DEMO data.',
  'Use gloves and mask while handling. DEMO data.',
  p.registration
from (
  values
    ('UREA-ENG-50', '896100100001', 'Engro Urea 50kg', 'اینگرو یوریا', 'granular', 'DEMO: high nitrogen urea', '46-0-0', 46::numeric, 0::numeric, 0::numeric, null::numeric, null::numeric, 'Wheat', 'REG-UREA-001', 4300::numeric, 4450::numeric, 4400::numeric, 4350::numeric, 'Urea', 'Engro'),
    ('UREA-FFC-50', '896100100002', 'Sona Urea 50kg', 'سونا یوریا', 'granular', 'DEMO: premium urea', '46-0-0', 46, 0, 0, null, null, 'Rice', 'REG-UREA-002', 4320, 4480, 4420, 4360, 'Urea', 'FFC'),
    ('DAP-FFC-50', '896100100003', 'Sona DAP 50kg', 'سونا ڈی اے پی', 'granular', 'DEMO: balanced phosphorus feed', '18-46-0', 18, 46, 0, null, null, 'Maize', 'REG-DAP-001', 11800, 12250, 12100, 11950, 'DAP', 'FFC'),
    ('DAP-ENG-50', '896100100004', 'Engro DAP 50kg', 'اینگرو ڈی اے پی', 'granular', 'DEMO: import grade DAP', '18-46-0', 18, 46, 0, null, null, 'Cotton', 'REG-DAP-002', 11750, 12200, 12050, 11900, 'DAP', 'Engro'),
    ('NPK-151515-50', '896100100005', 'NPK 15-15-15 50kg', 'این پی کے 15-15-15', 'compound', 'DEMO: general purpose compound', '15-15-15', 15, 15, 15, null, null, 'Vegetables', 'REG-NPK-001', 9300, 9700, 9550, 9400, 'NPK', 'Fatima'),
    ('NPK-202020-50', '896100100006', 'NPK 20-20-20 50kg', 'این پی کے 20-20-20', 'compound', 'DEMO: high nutrient compound', '20-20-20', 20, 20, 20, null, null, 'Sugarcane', 'REG-NPK-002', 10200, 10650, 10480, 10300, 'NPK', 'Fatima'),
    ('SOP-00-00-50-50', '896100100007', 'SOP 50kg', 'ایس او پی', 'powder', 'DEMO: chloride free potash', '0-0-50', 0, 0, 50, null, 18, 'Potato', 'REG-SOP-001', 13600, 14150, 14000, 13800, 'SOP', 'Sitara'),
    ('MICRO-ZN-10', '896100100008', 'Zinc Sulphate 10kg', 'زنک سلفیٹ', 'powder', 'DEMO: zinc correction', '0-0-0', 0, 0, 0, 33, 17, 'Rice', 'REG-MICRO-001', 2350, 2600, 2520, 2420, 'Micronutrients', 'Sitara'),
    ('MICRO-BORON-5', '896100100009', 'Boron Plus 5kg', 'بورون پلس', 'powder', 'DEMO: boron blend', '0-0-0', 0, 0, 0, null, null, 'Cotton', 'REG-MICRO-002', 1850, 2100, 2020, 1900, 'Micronutrients', 'Engro'),
    ('MICRO-MIX-10', '896100100010', 'Micro Mix 10kg', 'مائیکرو مکس', 'powder', 'DEMO: trace nutrient mix', '0-0-0', 0, 0, 0, 5, 6, 'Orchards', 'REG-MICRO-003', 3200, 3550, 3450, 3300, 'Micronutrients', 'FFC'),
    ('UREA-CAN-50', '896100100011', 'CAN 50kg', 'کین', 'granular', 'DEMO: calcium ammonium nitrate', '26-0-0', 26, 0, 0, null, null, 'Wheat', 'REG-UREA-003', 5200, 5500, 5400, 5300, 'Urea', 'Fatima'),
    ('DAP-PREMIUM-50', '896100100012', 'Premium DAP 50kg', 'پریمیم ڈی اے پی', 'granular', 'DEMO: premium DAP grade', '18-46-0', 18, 46, 0, null, null, 'Rice', 'REG-DAP-003', 12050, 12500, 12350, 12150, 'DAP', 'Fatima'),
    ('NPK-128122-50', '896100100013', 'NPK 12-8-22 50kg', 'این پی کے 12-8-22', 'compound', 'DEMO: fruit fertilizer blend', '12-8-22', 12, 8, 22, null, null, 'Mango', 'REG-NPK-003', 9800, 10300, 10150, 9950, 'NPK', 'Engro'),
    ('NPK-25105-50', '896100100014', 'NPK 25-10-5 50kg', 'این پی کے 25-10-5', 'compound', 'DEMO: high nitrogen blend', '25-10-5', 25, 10, 5, null, null, 'Maize', 'REG-NPK-004', 9650, 10100, 9950, 9750, 'NPK', 'FFC'),
    ('SOP-GRAN-50', '896100100015', 'Granular SOP 50kg', 'گرینولر ایس او پی', 'granular', 'DEMO: granular SOP grade', '0-0-50', 0, 0, 50, null, 17, 'Vegetables', 'REG-SOP-002', 13800, 14300, 14150, 13950, 'SOP', 'Sitara'),
    ('UREA-NEEM-50', '896100100016', 'Neem Coated Urea 50kg', 'نیم کوٹڈ یوریا', 'granular', 'DEMO: slow-release urea', '44-0-0', 44, 0, 0, null, null, 'Sugarcane', 'REG-UREA-004', 4700, 4950, 4850, 4750, 'Urea', 'Engro'),
    ('MICRO-CALMAG-25', '896100100017', 'CalMag Mix 25kg', 'کیل میگ مکس', 'powder', 'DEMO: calcium magnesium blend', '0-0-0', 0, 0, 0, null, 11, 'Tomato', 'REG-MICRO-004', 4200, 4550, 4450, 4300, 'Micronutrients', 'Sitara'),
    ('DAP-ZN-50', '896100100018', 'DAP + Zinc 50kg', 'ڈی اے پی زنک', 'granular', 'DEMO: fortified DAP with zinc', '18-45-0', 18, 45, 0, 1.5, null, 'Cotton', 'REG-DAP-004', 12300, 12750, 12600, 12400, 'DAP', 'Engro'),
    ('NPK-101010-50', '896100100019', 'NPK 10-10-10 50kg', 'این پی کے 10-10-10', 'compound', 'DEMO: starter fertilizer blend', '10-10-10', 10, 10, 10, null, null, 'Vegetables', 'REG-NPK-005', 8800, 9200, 9050, 8900, 'NPK', 'FFC'),
    ('MICRO-SULFUR-25', '896100100020', 'Sulfur Bentonite 25kg', 'سلفر بینٹونائٹ', 'granular', 'DEMO: soil sulfur conditioner', '0-0-0', 0, 0, 0, null, 75, 'Oilseed', 'REG-MICRO-005', 2100, 2400, 2320, 2200, 'Micronutrients', 'Fatima')
) as p(
  sku, barcode, name, urdu_name, product_type, description, npk_ratio,
  n_percent, p_percent, k_percent, zn_percent, s_percent,
  crop, registration, purchase_price, sale_price, wholesale_price, minimum_sale_price,
  category_name, brand_name
)
join public.product_categories c
  on c.business_id = '11111111-1111-1111-1111-111111111111' and c.name = p.category_name
join public.product_brands b
  on b.business_id = '11111111-1111-1111-1111-111111111111' and b.name = p.brand_name
on conflict (business_id, sku) do nothing;

insert into public.suppliers (business_id, name, company, phone, city, tax_number, credit_limit, opening_balance, notes)
values
  ('11111111-1111-1111-1111-111111111111', 'Engro Fertilizers Supply', 'Engro Fertilizers Limited', '+92-21-1111111', 'Karachi', 'TAX-ENG-01', 1500000, 250000, 'DEMO supplier record'),
  ('11111111-1111-1111-1111-111111111111', 'Fauji Fertilizer Distribution', 'Fauji Fertilizer Company', '+92-51-2222222', 'Islamabad', 'TAX-FFC-01', 1300000, 180000, 'DEMO supplier record'),
  ('11111111-1111-1111-1111-111111111111', 'Sitara Chemicals Trade', 'Sitara Chemicals', '+92-41-3333333', 'Faisalabad', 'TAX-SIT-01', 900000, 120000, 'DEMO supplier record'),
  ('11111111-1111-1111-1111-111111111111', 'Fatima Fertilizer Sales', 'Fatima Fertilizer', '+92-42-4444444', 'Lahore', 'TAX-FAT-01', 1100000, 150000, 'DEMO supplier record'),
  ('11111111-1111-1111-1111-111111111111', 'Pak Agro Inputs', 'Pak Agro Inputs', '+92-61-5555555', 'Multan', 'TAX-PAK-01', 700000, 50000, 'DEMO supplier record')
on conflict do nothing;

insert into public.customers (business_id, name, phone, cnic, village, city, farm_name, farm_location, land_acres, credit_limit, opening_balance, notes)
values
  ('11111111-1111-1111-1111-111111111111', 'محمد اقبال', '+92-300-2000001', '35202-1234567-1', 'Chak 101', 'Faisalabad', 'Iqbal Farms', 'Near Canal Road', 22, 120000, 15000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'احمد نواز', '+92-300-2000002', '35202-2234567-2', 'Chak 88', 'Sahiwal', 'Nawaz Agro Farm', 'GT Road', 30, 180000, 22000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'کاشف حسین', '+92-300-2000003', '35202-3234567-3', 'Kot Momin', 'Sargodha', 'Hussain Fields', 'Bhalwal Road', 17, 90000, 5000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'نعیم اختر', '+92-300-2000004', '35202-4234567-4', 'Jalalpur', 'Multan', 'Akhtar Farmhouse', 'Lodhran Road', 45, 250000, 34000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'علی رضا', '+92-300-2000005', '35202-5234567-5', 'Khanpur', 'Rahim Yar Khan', 'Raza Agriculture', 'Khanpur Canal', 28, 160000, 18000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'بشیر احمد', '+92-300-2000006', '35202-6234567-6', 'Qadirpur', 'Okara', 'Basheer Farm', 'Bypass Okara', 19, 85000, 4500, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'ارشد محمود', '+92-300-2000007', '35202-7234567-7', 'Mailsi', 'Vehari', 'Arshad Agro', 'Mailsi Road', 26, 140000, 12000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'سعید انور', '+92-300-2000008', '35202-8234567-8', 'Burewala', 'Vehari', 'Anwar Farms', 'Model Town', 33, 190000, 25000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'جمیل اختر', '+92-300-2000009', '35202-9234567-9', 'Shujabad', 'Multan', 'Jameel Green Farm', 'Head Muhammad Wala', 14, 60000, 3000, 'DEMO customer record'),
  ('11111111-1111-1111-1111-111111111111', 'رضوان کریم', '+92-300-2000010', '35202-0234567-0', 'Tandlianwala', 'Faisalabad', 'Rizwan Agri', 'Tandlianwala Road', 38, 210000, 29000, 'DEMO customer record')
on conflict do nothing;

insert into public.product_batches (
  business_id,
  product_id,
  warehouse_id,
  batch_number,
  manufacturing_date,
  expiry_date,
  purchase_price,
  quantity_received,
  quantity_remaining
)
select
  '11111111-1111-1111-1111-111111111111',
  p.id,
  case
    when row_number() over (order by p.created_at, p.id) % 3 = 1 then '41111111-1111-1111-1111-111111111111'::uuid
    when row_number() over (order by p.created_at, p.id) % 3 = 2 then '42222222-2222-2222-2222-222222222222'::uuid
    else '43333333-3333-3333-3333-333333333333'::uuid
  end,
  'BATCH-' || lpad(row_number() over (order by p.created_at, p.id)::text, 4, '0'),
  (current_date - interval '40 days')::date,
  (current_date + interval '320 days')::date,
  p.purchase_price,
  100,
  100
from public.products p
where p.business_id = '11111111-1111-1111-1111-111111111111'
on conflict (business_id, product_id, batch_number) do nothing;

insert into public.business_settings (business_id, setting_key, setting_value)
values
  ('11111111-1111-1111-1111-111111111111', 'demo_mode', '{"enabled": true, "note": "DEMO data"}'),
  ('11111111-1111-1111-1111-111111111111', 'invoice_preferences', '{"prefix": "INV", "language": "en", "currency": "PKR"}')
on conflict (business_id, setting_key) do nothing;
