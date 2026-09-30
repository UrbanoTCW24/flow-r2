-- ITAD Core — proyecto fmqtkuyefbawfpeijjnq
-- También: 002_itad_lab_orders.sql (sync recepciones)
-- Ejecutar en: Supabase Dashboard → SQL Editor → Run

create table if not exists public.itad_order_intakes (
  id uuid primary key default gen_random_uuid(),
  client_project_order text unique,
  po_reference text,
  tc_id text,
  memo_text text,
  form_json jsonb,
  country_code text not null default 'GT',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists itad_order_intakes_tc_id_idx
  on public.itad_order_intakes (tc_id);

alter table public.itad_order_intakes enable row level security;

-- MVP lab: anon puede leer/escribir intakes (ajuste RLS en producción)
drop policy if exists "itad_anon_all_intakes" on public.itad_order_intakes;
create policy "itad_anon_all_intakes"
  on public.itad_order_intakes
  for all
  to anon, authenticated
  using (true)
  with check (true);

-- Buckets Storage (fotos recepción + PDF Blancco)
insert into storage.buckets (id, name, public)
values
  ('itad-photos', 'itad-photos', true),
  ('itad-pdfs', 'itad-pdfs', true)
on conflict (id) do nothing;

drop policy if exists "itad_photos_anon_rw" on storage.objects;
create policy "itad_photos_anon_rw"
  on storage.objects for all to anon, authenticated
  using (bucket_id = 'itad-photos')
  with check (bucket_id = 'itad-photos');

drop policy if exists "itad_pdfs_anon_rw" on storage.objects;
create policy "itad_pdfs_anon_rw"
  on storage.objects for all to anon, authenticated
  using (bucket_id = 'itad-pdfs')
  with check (bucket_id = 'itad-pdfs');
