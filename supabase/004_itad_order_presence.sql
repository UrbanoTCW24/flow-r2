-- Presencia de operadores por orden (varios teléfonos en la misma TC)
-- Proyecto: fmqtkuyefbawfpeijjnq

create table if not exists public.itad_order_presence (
  id uuid primary key default gen_random_uuid(),
  lab_order_id text not null,
  session_id text not null,
  operator_name text not null default 'Operador',
  device_label text,
  last_seen_at timestamptz not null default now(),
  unique (lab_order_id, session_id)
);

create index if not exists itad_presence_order_seen_idx
  on public.itad_order_presence (lab_order_id, last_seen_at desc);

alter table public.itad_order_presence enable row level security;

drop policy if exists "itad_anon_all_order_presence" on public.itad_order_presence;
create policy "itad_anon_all_order_presence"
  on public.itad_order_presence
  for all
  to anon, authenticated
  using (true)
  with check (true);
