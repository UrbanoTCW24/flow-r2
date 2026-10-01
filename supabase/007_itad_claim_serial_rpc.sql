-- Claim atómico de una serie en itad_lab_orders.items (evita SELECT+UPDATE cliente en ráfaga)
-- Proyecto: fmqtkuyefbawfpeijjnq — ejecutar en SQL Editor tras 002_itad_lab_orders.sql

create or replace function public.itad_normalize_serial(raw text)
returns text
language sql
immutable
as $$
  select upper(regexp_replace(coalesce(raw, ''), '[^A-Z0-9]', '', 'g'));
$$;

create or replace function public.itad_claim_serial_received(
  p_lab_order_id text,
  p_serial text,
  p_operator text,
  p_session text,
  p_via text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_items jsonb;
  v_norm text;
  v_idx int := -1;
  v_row jsonb;
  v_received_at timestamptz := now();
  i int;
  el jsonb;
begin
  if coalesce(p_lab_order_id, '') = '' then
    return jsonb_build_object('ok', false, 'error', 'MISSING_LAB_ORDER_ID');
  end if;

  v_norm := public.itad_normalize_serial(p_serial);
  if length(v_norm) < 4 then
    return jsonb_build_object('ok', false, 'error', 'INVALID_SERIAL');
  end if;

  select lo.items
    into v_items
    from public.itad_lab_orders lo
   where lo.lab_order_id = p_lab_order_id
   for update;

  if v_items is null then
    return jsonb_build_object('ok', false, 'error', 'Orden no encontrada en la nube');
  end if;

  if jsonb_typeof(v_items) <> 'array' then
    v_items := '[]'::jsonb;
  end if;

  for i in 0 .. jsonb_array_length(v_items) - 1 loop
    el := v_items -> i;
    if public.itad_normalize_serial(el ->> 'serial') = v_norm then
      v_idx := i;
      exit;
    end if;
  end loop;

  if v_idx < 0 then
    return jsonb_build_object('ok', false, 'error', 'Serie no está en la orden autorizada');
  end if;

  v_row := v_items -> v_idx;

  if coalesce(v_row ->> 'status', '') = 'RECEIVED' then
    return jsonb_build_object(
      'ok', false,
      'reason', 'ALREADY_RECEIVED',
      'by', coalesce(v_row ->> 'receivedByName', 'otro operador'),
      'at', v_row ->> 'scannedAt'
    );
  end if;

  v_items := jsonb_set(v_items, array[v_idx::text, 'status'], '"RECEIVED"', false);
  v_items := jsonb_set(
    v_items,
    array[v_idx::text, 'scannedAt'],
    to_jsonb(to_char(v_received_at at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')),
    true
  );
  v_items := jsonb_set(v_items, array[v_idx::text, 'scanMethod'], to_jsonb(coalesce(nullif(p_via, ''), 'pistol_scan')), true);
  v_items := jsonb_set(v_items, array[v_idx::text, 'receivedByName'], to_jsonb(coalesce(p_operator, '')), true);
  v_items := jsonb_set(v_items, array[v_idx::text, 'receivedBySession'], to_jsonb(coalesce(p_session, '')), true);

  update public.itad_lab_orders
     set items = v_items,
         updated_at = v_received_at
   where lab_order_id = p_lab_order_id;

  return jsonb_build_object(
    'ok', true,
    'item', v_items -> v_idx,
    'received_at', v_received_at
  );
end;
$$;

grant execute on function public.itad_claim_serial_received(text, text, text, text, text)
  to anon, authenticated;

grant execute on function public.itad_normalize_serial(text)
  to anon, authenticated;
