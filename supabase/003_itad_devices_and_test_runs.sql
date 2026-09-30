-- Catálogo por serie + recepción normalizada (proyecto fmqtkuyefbawfpeijjnq)

create table if not exists public.itad_devices (
  id uuid primary key default gen_random_uuid(),
  serial_normalized text not null unique,
  serial_raw text,
  vendor text,
  model text,
  category text,
  first_seen_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  last_tc_id text,
  last_lab_order_id text,
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists itad_devices_last_tc_idx on public.itad_devices (last_tc_id);

create table if not exists public.itad_test_runs (
  id uuid primary key default gen_random_uuid(),
  lab_order_id text not null unique,
  tc_id text,
  kind text not null default 'reception',
  status text not null default 'OPEN',
  label text,
  order_metadata jsonb,
  workflow jsonb,
  country_code text not null default 'GT',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists itad_test_runs_tc_idx on public.itad_test_runs (tc_id);

create table if not exists public.itad_test_run_assets (
  id uuid primary key default gen_random_uuid(),
  test_run_id uuid not null references public.itad_test_runs(id) on delete cascade,
  serial_normalized text not null,
  item_no integer,
  vendor text,
  model text,
  category text,
  asset_status text not null default 'PENDING',
  received_at timestamptz,
  scan_method text,
  cosmetic_note text,
  photo_storage_path text,
  photo_public_url text,
  photo_size_bytes bigint,
  disks jsonb not null default '[]'::jsonb,
  cpu text,
  ram text,
  battery_status text,
  final_status text,
  report_pdf_path text,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  unique (test_run_id, serial_normalized)
);

create index if not exists itad_test_run_assets_serial_idx on public.itad_test_run_assets (serial_normalized);

alter table public.itad_devices enable row level security;
alter table public.itad_test_runs enable row level security;
alter table public.itad_test_run_assets enable row level security;

drop policy if exists "itad_anon_devices" on public.itad_devices;
create policy "itad_anon_devices" on public.itad_devices for all to anon, authenticated using (true) with check (true);

drop policy if exists "itad_anon_test_runs" on public.itad_test_runs;
create policy "itad_anon_test_runs" on public.itad_test_runs for all to anon, authenticated using (true) with check (true);

drop policy if exists "itad_anon_test_run_assets" on public.itad_test_run_assets;
create policy "itad_anon_test_run_assets" on public.itad_test_run_assets for all to anon, authenticated using (true) with check (true);
