-- Run this in Supabase SQL Editor
-- Enable UUID generation used by gen_random_uuid()
create extension if not exists pgcrypto;

-- 1) Table to store markers
create table if not exists public.markers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  username text not null,
  title text,
  color text not null,
  lat double precision not null,
  lng double precision not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Keep updated_at current
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_markers_updated_at on public.markers;
create trigger trg_markers_updated_at
before update on public.markers
for each row
execute function public.set_updated_at();

-- 2) Enable RLS
alter table public.markers enable row level security;

-- 3) Policies
-- Anyone can read markers
drop policy if exists "Markers are readable by everyone" on public.markers;
create policy "Markers are readable by everyone"
on public.markers for select
to anon, authenticated
using (true);

-- Only authenticated users can insert their own marker
drop policy if exists "Users can insert their own markers" on public.markers;
create policy "Users can insert their own markers"
on public.markers for insert
to authenticated
with check (auth.uid() = user_id);

-- Only owner can update
drop policy if exists "Users can update their own markers" on public.markers;
create policy "Users can update their own markers"
on public.markers for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Only owner can delete
drop policy if exists "Users can delete their own markers" on public.markers;
create policy "Users can delete their own markers"
on public.markers for delete
to authenticated
using (auth.uid() = user_id);

-- 4) Realtime (optional but recommended)
-- In the Dashboard, enable Realtime for this table if needed.
alter publication supabase_realtime add table public.markers;
