-- Evita que un dispositivo "reviva" órdenes borradas en otro (upsert tras delete)
-- Proyecto: fmqtkuyefbawfpeijjnq

create table if not exists public.itad_lab_order_tombstones (
  lab_order_id text primary key,
  deleted_at timestamptz not null default now(),
  deleted_by text
);

alter table public.itad_lab_order_tombstones enable row level security;

drop policy if exists "itad_anon_tombstones" on public.itad_lab_order_tombstones;
create policy "itad_anon_tombstones"
  on public.itad_lab_order_tombstones
  for all
  to anon, authenticated
  using (true)
  with check (true);
