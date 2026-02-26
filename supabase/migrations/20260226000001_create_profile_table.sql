-- Migration: create_profile_table
-- Creates the user profile table with RLS policies and new-user trigger.

create table public.profile (
  profile_id uuid references auth.users(id) on delete cascade primary key,
  email text,
  is_performer boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profile enable row level security;

create policy "Users can view own profile"
  on public.profile
  for select
  to authenticated
  using ((select auth.uid()) = profile_id);

create policy "Users can update own profile"
  on public.profile
  for update
  to authenticated
  using ((select auth.uid()) = profile_id)
  with check ((select auth.uid()) = profile_id);

-- Trigger function: insert a profile row whenever a new auth user is created.
-- security definer + search_path = '' enforces fully qualified names inside the body.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profile (profile_id, email)
  values (new.id, new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
