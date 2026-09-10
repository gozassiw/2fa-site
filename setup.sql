-- =====================================================
--  Run this ONCE in Supabase → SQL Editor → New query → Run
--  BEFORE running: change you@example.com (line 9) to your admin email, in lowercase
-- =====================================================

-- 1. Who is the admin
create or replace function public.is_admin() returns boolean
language sql stable as $$
  select coalesce(auth.jwt() ->> 'email', '') = lower('walletajo292@gmail.com')
$$;

-- 2. The ads table
create table if not exists public.ads (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text,
  image_url   text,
  link        text not null,
  position    int  not null default 1 check (position between 1 and 6),
  active      boolean not null default true,
  ends_on     date,
  clicks      int  not null default 0,
  created_at  timestamptz not null default now()
);

alter table public.ads enable row level security;

grant select on public.ads to anon, authenticated;
grant insert, update, delete on public.ads to authenticated;

-- Visitors only see ads that are switched on and not expired
drop policy if exists "Visitors see live ads" on public.ads;
create policy "Visitors see live ads" on public.ads
  for select using (active and (ends_on is null or ends_on >= current_date));

-- Only the admin can see everything and add / edit / delete
drop policy if exists "Admin manages ads" on public.ads;
create policy "Admin manages ads" on public.ads
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- 3. Maximum of 6 ads
create or replace function public.limit_ads() returns trigger
language plpgsql as $$
begin
  if (select count(*) from public.ads) >= 6 then
    raise exception 'You already have 6 ads. Delete one before adding another.';
  end if;
  return new;
end $$;

drop trigger if exists ads_limit on public.ads;
create trigger ads_limit before insert on public.ads
  for each row execute function public.limit_ads();

-- 4. Count clicks (so you can show advertisers their results)
create or replace function public.count_click(ad_id uuid) returns void
language sql security definer set search_path = public as $$
  update public.ads set clicks = clicks + 1 where id = ad_id and active;
$$;
revoke all on function public.count_click(uuid) from public;
grant execute on function public.count_click(uuid) to anon, authenticated;

-- 5. Storage for banner images
insert into storage.buckets (id, name, public)
values ('ad-images', 'ad-images', true)
on conflict (id) do nothing;

drop policy if exists "Admin uploads ad images" on storage.objects;
create policy "Admin uploads ad images" on storage.objects
  for insert to authenticated with check (bucket_id = 'ad-images' and public.is_admin());

drop policy if exists "Admin deletes ad images" on storage.objects;
create policy "Admin deletes ad images" on storage.objects
  for delete to authenticated using (bucket_id = 'ad-images' and public.is_admin());

drop policy if exists "Admin lists ad images" on storage.objects;
create policy "Admin lists ad images" on storage.objects
  for select to authenticated using (bucket_id = 'ad-images' and public.is_admin());

-- 6. Visitor stats (counts only — no names, IPs or keys are stored)
create table if not exists public.site_stats (
  day      date primary key,
  views    int not null default 0,
  visitors int not null default 0
);
alter table public.site_stats enable row level security;
grant select on public.site_stats to authenticated;

drop policy if exists "Admin reads stats" on public.site_stats;
create policy "Admin reads stats" on public.site_stats
  for select to authenticated using (public.is_admin());

create or replace function public.count_visit(is_new boolean default false) returns void
language sql security definer set search_path = public as $$
  insert into public.site_stats (day, views, visitors)
  values ((now() at time zone 'Africa/Lagos')::date, 1, case when is_new then 1 else 0 end)
  on conflict (day) do update
    set views    = site_stats.views + 1,
        visitors = site_stats.visitors + (case when is_new then 1 else 0 end);
$$;
revoke all on function public.count_visit(boolean) from public;
grant execute on function public.count_visit(boolean) to anon, authenticated;
