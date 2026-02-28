-- Run this in Supabase SQL Editor
-- Enable UUID generation used by gen_random_uuid()
create extension if not exists pgcrypto;

-- 1) Table to store markers
create table if not exists public.markers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  username text not null,
  title text,
  description text,
  color text not null,
  lat double precision not null,
  lng double precision not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- If the table already existed, ensure the new column is present
alter table public.markers add column if not exists description text;

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
do $$
begin
  alter publication supabase_realtime add table public.markers;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;

-- 4b) Shared editable color key (legend)
create table if not exists public.color_key (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  color text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Re-use the same updated_at trigger function
drop trigger if exists trg_color_key_updated_at on public.color_key;
create trigger trg_color_key_updated_at
before update on public.color_key
for each row
execute function public.set_updated_at();

alter table public.color_key enable row level security;

drop policy if exists "Color key is readable by everyone" on public.color_key;
create policy "Color key is readable by everyone"
on public.color_key for select
to anon, authenticated
using (true);

drop policy if exists "Authenticated users can edit color key" on public.color_key;
create policy "Authenticated users can edit color key"
on public.color_key for all
to authenticated
using (true)
with check (true);

-- Optional but recommended for live updates
do $$
begin
  alter publication supabase_realtime add table public.color_key;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;

-- 5) User profiles (user_id + username)
-- Supabase Auth stores passwords securely (hashed) and does NOT allow reading them back.
-- This table is the safe way to keep a list of teammates and their user IDs.

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Profiles are readable by authenticated users" on public.profiles;
create policy "Profiles are readable by authenticated users"
on public.profiles for select
to authenticated
using (true);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
on public.profiles for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
on public.profiles for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Automatically create a profile row when a new auth user is created
create or replace function public.handle_new_user_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  uname text;
begin
  uname := coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1));
  insert into public.profiles (user_id, username)
  values (new.id, uname)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
after insert on auth.users
for each row execute function public.handle_new_user_profile();

-- Optional: include profiles in Realtime
-- alter publication supabase_realtime add table public.profiles;
