-- LuxeJewel schema: catalog, profiles, addresses, carts, wishlists, orders.
-- Money is stored as integer minor units (cents).

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Private settings (no RLS policies => only SECURITY DEFINER functions read it)
-- ---------------------------------------------------------------------------
create table if not exists public.app_settings (
  key text primary key,
  value text not null
);
alter table public.app_settings enable row level security;
insert into public.app_settings (key, value)
values ('demo_payments_enabled', 'true')
on conflict (key) do nothing;

-- ---------------------------------------------------------------------------
-- Catalog (public read, writes only via service role / dashboard)
-- ---------------------------------------------------------------------------
create table if not exists public.categories (
  id smallint generated always as identity primary key,
  name text not null unique,
  sort_order smallint not null default 0
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text not null default '',
  material text,
  category_id smallint not null references public.categories (id),
  price_cents integer not null check (price_cents >= 0),
  rating numeric(2, 1) not null default 0 check (rating between 0 and 5),
  image_path text not null,
  stock integer not null default 0 check (stock >= 0),
  is_active boolean not null default true,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists products_category_idx on public.products (category_id);
create index if not exists products_active_sort_idx on public.products (is_active, sort_order);

alter table public.categories enable row level security;
alter table public.products enable row level security;

drop policy if exists "categories are public" on public.categories;
create policy "categories are public" on public.categories
  for select to anon, authenticated using (true);

drop policy if exists "active products are public" on public.products;
create policy "active products are public" on public.products
  for select to anon, authenticated using (is_active);

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '' check (char_length(full_name) <= 120),
  phone text check (char_length(phone) <= 32),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

drop policy if exists "own profile read" on public.profiles;
create policy "own profile read" on public.profiles
  for select to authenticated using (id = (select auth.uid()));
drop policy if exists "own profile update" on public.profiles;
create policy "own profile update" on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Addresses
-- ---------------------------------------------------------------------------
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  full_name text not null check (char_length(full_name) between 1 and 120),
  phone text not null check (char_length(phone) between 5 and 32),
  line1 text not null check (char_length(line1) between 1 and 200),
  line2 text check (char_length(line2) <= 200),
  city text not null check (char_length(city) between 1 and 100),
  postal_code text not null check (char_length(postal_code) between 3 and 12),
  country text not null default 'US' check (char_length(country) between 2 and 56),
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists addresses_user_idx on public.addresses (user_id);
create unique index if not exists addresses_one_default_idx
  on public.addresses (user_id) where is_default;
alter table public.addresses enable row level security;

drop policy if exists "own addresses" on public.addresses;
create policy "own addresses" on public.addresses
  for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Carts
-- ---------------------------------------------------------------------------
create table if not exists public.carts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique default auth.uid() references public.profiles (id) on delete cascade,
  updated_at timestamptz not null default now()
);
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete cascade,
  quantity integer not null check (quantity between 1 and 99),
  created_at timestamptz not null default now(),
  unique (cart_id, product_id)
);
create index if not exists cart_items_product_idx on public.cart_items (product_id);
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;

drop policy if exists "own cart read" on public.carts;
create policy "own cart read" on public.carts
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "own cart insert" on public.carts;
create policy "own cart insert" on public.carts
  for insert to authenticated with check (user_id = (select auth.uid()));

drop policy if exists "own cart items" on public.cart_items;
create policy "own cart items" on public.cart_items
  for all to authenticated
  using (exists (select 1 from public.carts c where c.id = cart_id and c.user_id = (select auth.uid())))
  with check (exists (select 1 from public.carts c where c.id = cart_id and c.user_id = (select auth.uid())));

-- Reject cart quantities above available stock or for inactive products.
create or replace function public.check_cart_item_stock()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_stock integer;
begin
  select stock into v_stock from public.products where id = new.product_id and is_active;
  if v_stock is null then
    raise exception 'Product is not available' using errcode = 'P0001';
  end if;
  if new.quantity > v_stock then
    raise exception 'Only % left in stock', v_stock using errcode = 'P0001';
  end if;
  return new;
end;
$$;
drop trigger if exists cart_items_stock_check on public.cart_items;
create trigger cart_items_stock_check
  before insert or update on public.cart_items
  for each row execute function public.check_cart_item_stock();

-- ---------------------------------------------------------------------------
-- Wishlists
-- ---------------------------------------------------------------------------
create table if not exists public.wishlists (
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);
create index if not exists wishlists_product_idx on public.wishlists (product_id);
alter table public.wishlists enable row level security;

drop policy if exists "own wishlist read" on public.wishlists;
create policy "own wishlist read" on public.wishlists
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "own wishlist insert" on public.wishlists;
create policy "own wishlist insert" on public.wishlists
  for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists "own wishlist delete" on public.wishlists;
create policy "own wishlist delete" on public.wishlists
  for delete to authenticated using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Orders (read-only for clients; created only through place_demo_order)
-- ---------------------------------------------------------------------------
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  user_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'placed'
    check (status in ('placed', 'processing', 'shipped', 'delivered', 'cancelled')),
  payment_mode text not null check (payment_mode in ('demo', 'live')),
  payment_status text not null
    check (payment_status in ('demo_completed', 'pending', 'paid', 'failed', 'refunded')),
  is_demo boolean generated always as (payment_mode = 'demo') stored,
  subtotal_cents integer not null check (subtotal_cents >= 0),
  shipping_cents integer not null check (shipping_cents >= 0),
  tax_cents integer not null check (tax_cents >= 0),
  total_cents integer not null check (total_cents >= 0),
  shipping_address jsonb not null,
  created_at timestamptz not null default now(),
  constraint demo_orders_never_paid check (
    payment_mode <> 'demo' or payment_status = 'demo_completed'
  )
);
create index if not exists orders_user_created_idx on public.orders (user_id, created_at desc);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_id uuid references public.products (id) on delete set null,
  product_name text not null,
  image_path text not null,
  unit_price_cents integer not null check (unit_price_cents >= 0),
  quantity integer not null check (quantity > 0),
  line_total_cents integer not null check (line_total_cents >= 0)
);
create index if not exists order_items_order_idx on public.order_items (order_id);
create index if not exists order_items_product_idx on public.order_items (product_id);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "own orders read" on public.orders;
create policy "own orders read" on public.orders
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "own order items read" on public.order_items;
create policy "own order items read" on public.order_items
  for select to authenticated
  using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = (select auth.uid())));

-- Server-side demo checkout: prices, totals and payment status are computed here,
-- never trusted from the client. Inventory is validated but not decremented.
create or replace function public.place_demo_order(p_address_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_cart uuid;
  v_address public.addresses%rowtype;
  v_subtotal integer := 0;
  v_shipping integer;
  v_tax integer;
  v_order uuid;
  v_bad text;
begin
  if v_user is null then
    raise exception 'Not authenticated' using errcode = '42501';
  end if;
  if coalesce((select value from public.app_settings where key = 'demo_payments_enabled'), 'false') <> 'true' then
    raise exception 'Demo payments are disabled' using errcode = 'P0001';
  end if;

  select * into v_address from public.addresses where id = p_address_id and user_id = v_user;
  if not found then
    raise exception 'Shipping address not found' using errcode = 'P0001';
  end if;

  select id into v_cart from public.carts where user_id = v_user;
  if v_cart is null or not exists (select 1 from public.cart_items where cart_id = v_cart) then
    raise exception 'Your cart is empty' using errcode = 'P0001';
  end if;

  select p.name into v_bad
  from public.cart_items ci
  left join public.products p on p.id = ci.product_id
  where ci.cart_id = v_cart and (p.id is null or not p.is_active or ci.quantity > p.stock)
  limit 1;
  if found then
    raise exception 'Not enough stock for %', coalesce(v_bad, 'an item') using errcode = 'P0001';
  end if;

  select coalesce(sum(p.price_cents * ci.quantity), 0) into v_subtotal
  from public.cart_items ci join public.products p on p.id = ci.product_id
  where ci.cart_id = v_cart;

  v_shipping := case when v_subtotal > 0 then 5000 else 0 end;
  v_tax := round(v_subtotal * 0.08);

  insert into public.orders (
    order_number, user_id, payment_mode, payment_status,
    subtotal_cents, shipping_cents, tax_cents, total_cents, shipping_address
  ) values (
    'DEMO-' || to_char(now(), 'YYMMDD') || '-' || upper(substr(md5(gen_random_uuid()::text), 1, 6)),
    v_user, 'demo', 'demo_completed',
    v_subtotal, v_shipping, v_tax, v_subtotal + v_shipping + v_tax,
    jsonb_build_object(
      'full_name', v_address.full_name, 'phone', v_address.phone,
      'line1', v_address.line1, 'line2', v_address.line2,
      'city', v_address.city, 'postal_code', v_address.postal_code,
      'country', v_address.country)
  ) returning id into v_order;

  insert into public.order_items (order_id, product_id, product_name, image_path,
                                  unit_price_cents, quantity, line_total_cents)
  select v_order, p.id, p.name, p.image_path, p.price_cents, ci.quantity, p.price_cents * ci.quantity
  from public.cart_items ci join public.products p on p.id = ci.product_id
  where ci.cart_id = v_cart;

  delete from public.cart_items where cart_id = v_cart;
  return v_order;
end;
$$;
revoke all on function public.place_demo_order(uuid) from public, anon;
grant execute on function public.place_demo_order(uuid) to authenticated;
revoke all on function public.check_cart_item_stock() from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- New user bootstrap: profile + cart
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    left(coalesce(new.raw_user_meta_data ->> 'full_name', ''), 120),
    nullif(left(coalesce(new.raw_user_meta_data ->> 'phone', ''), 32), '')
  )
  on conflict (id) do nothing;
  insert into public.carts (user_id) values (new.id) on conflict (user_id) do nothing;
  return new;
end;
$$;
revoke all on function public.handle_new_user() from public, anon, authenticated;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill for users created before this migration.
insert into public.profiles (id, full_name)
select u.id, coalesce(u.raw_user_meta_data ->> 'full_name', '') from auth.users u
on conflict (id) do nothing;
insert into public.carts (user_id) select id from public.profiles on conflict (user_id) do nothing;

-- ---------------------------------------------------------------------------
-- Storage: public-read avatars, users write only inside "<uid>/"
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "avatar insert own folder" on storage.objects;
create policy "avatar insert own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
drop policy if exists "avatar update own folder" on storage.objects;
create policy "avatar update own folder" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
drop policy if exists "avatar delete own folder" on storage.objects;
create policy "avatar delete own folder" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
