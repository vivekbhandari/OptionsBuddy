-- Supabase setup for OptionsBuddy
-- Run this in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  finnhub_key text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists finnhub_key text,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.update_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute procedure public.update_updated_at();

create table if not exists public.positions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  ticker text not null,
  strategy_id text not null,
  strategy_name text not null,
  entry_price numeric not null default 0,
  entry_iv numeric default 0,
  entry_rate numeric default 0,
  entry_date date,
  expiration_date date,
  notes text,
  status text not null default 'open',
  legs jsonb not null default '[]'::jsonb,
  net_cost numeric not null default 0,
  closed_pl numeric,
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.positions
  alter column id type uuid using id::uuid;

alter table public.positions
  add column if not exists user_id uuid,
  add column if not exists ticker text,
  add column if not exists strategy_id text,
  add column if not exists strategy_name text,
  add column if not exists entry_price numeric default 0,
  add column if not exists entry_iv numeric default 0,
  add column if not exists entry_rate numeric default 0,
  add column if not exists entry_date date,
  add column if not exists expiration_date date,
  add column if not exists notes text,
  add column if not exists status text default 'open',
  add column if not exists legs jsonb default '[]'::jsonb,
  add column if not exists net_cost numeric default 0,
  add column if not exists closed_pl numeric,
  add column if not exists closed_at timestamptz,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

drop trigger if exists positions_set_updated_at on public.positions;
create trigger positions_set_updated_at
before update on public.positions
for each row execute procedure public.update_updated_at();

alter table public.profiles enable row level security;
alter table public.positions enable row level security;

drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can insert own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Users can delete own profile" on public.profiles;
drop policy if exists "Users can view own positions" on public.positions;
drop policy if exists "Users can insert own positions" on public.positions;
drop policy if exists "Users can update own positions" on public.positions;
drop policy if exists "Users can delete own positions" on public.positions;

create policy "Users can view own profile"
on public.profiles
for select
using (auth.uid() = id);

create policy "Users can insert own profile"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "Users can update own profile"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "Users can delete own profile"
on public.profiles
for delete
using (auth.uid() = id);

create policy "Users can view own positions"
on public.positions
for select
using (auth.uid() = user_id);

create policy "Users can insert own positions"
on public.positions
for insert
with check (auth.uid() = user_id);

create policy "Users can update own positions"
on public.positions
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete own positions"
on public.positions
for delete
using (auth.uid() = user_id);

-- sanity checks
select id, finnhub_key, created_at, updated_at
from public.profiles
limit 10;

select id, user_id, ticker, status, updated_at
from public.positions
limit 10;
