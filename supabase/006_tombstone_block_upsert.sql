-- Impide revivir órdenes marcadas como borradas (cualquier dispositivo / versión vieja)

create or replace function public.itad_reject_tombstoned_lab_order()
returns trigger
language plpgsql
as $$
begin
  if exists (
    select 1 from public.itad_lab_order_tombstones t
    where t.lab_order_id = new.lab_order_id
  ) then
    raise exception 'itad_lab_order_tombstoned:%', new.lab_order_id
      using errcode = '23505';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_itad_lab_orders_not_tombstoned on public.itad_lab_orders;
create trigger trg_itad_lab_orders_not_tombstoned
  before insert or update on public.itad_lab_orders
  for each row
  execute function public.itad_reject_tombstoned_lab_order();

-- Limpia filas huérfanas ya tombstone
delete from public.itad_lab_orders lo
where exists (
  select 1 from public.itad_lab_order_tombstones t
  where t.lab_order_id = lo.lab_order_id
);
