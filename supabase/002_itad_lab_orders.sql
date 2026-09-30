-- Sincroniza órdenes abiertas del lab (OrderStore) → Supabase
-- Proyecto: fmqtkuyefbawfpeijjnq

create table if not exists public.itad_lab_orders (
  id uuid primary key default gen_random_uuid(),
  lab_order_id text not null unique,
  tc_id text unique,
  client_project_order text,
  po_reference text,
  status text not null default 'OPEN',
  label text,
  order_metadata jsonb,
  items jsonb not null default '[]'::jsonb,
  workflow jsonb,
  blancco_meta jsonb,
  country_code text not null default 'GT',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists itad_lab_orders_tc_idx on public.itad_lab_orders (tc_id);
create index if not exists itad_lab_orders_ord_idx on public.itad_lab_orders (client_project_order);

alter table public.itad_lab_orders enable row level security;

drop policy if exists "itad_anon_all_lab_orders" on public.itad_lab_orders;
create policy "itad_anon_all_lab_orders"
  on public.itad_lab_orders
  for all
  to anon, authenticated
  using (true)
  with check (true);
