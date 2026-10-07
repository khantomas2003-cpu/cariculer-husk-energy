-- CARICULER HUSK ENERGY — SUPABASE SETUP
-- Run this in Supabase SQL Editor AFTER creating your project.
-- Then create one admin user in Authentication > Users.
-- IMPORTANT: disable public sign-ups after creating your admin account.

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  achievement_date date,
  file_path text not null,
  file_url text not null,
  file_type text,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.achievements enable row level security;

drop policy if exists "Public can read achievements" on public.achievements;
create policy "Public can read achievements"
on public.achievements for select
to anon, authenticated
using (true);

drop policy if exists "Admins can insert achievements" on public.achievements;
create policy "Admins can insert achievements"
on public.achievements for insert
to authenticated
with check (auth.uid() = created_by);

drop policy if exists "Admins can update achievements" on public.achievements;
create policy "Admins can update achievements"
on public.achievements for update
to authenticated
using (auth.uid() = created_by)
with check (auth.uid() = created_by);

drop policy if exists "Admins can delete achievements" on public.achievements;
create policy "Admins can delete achievements"
on public.achievements for delete
to authenticated
using (auth.uid() = created_by);

-- Storage bucket. Public read is intentional because achievement images/documents
-- are meant to be displayed on the public company website.
insert into storage.buckets (id, name, public)
values ('achievements', 'achievements', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can view achievement files" on storage.objects;
create policy "Public can view achievement files"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'achievements');

drop policy if exists "Authenticated users can upload achievement files" on storage.objects;
create policy "Authenticated users can upload achievement files"
on storage.objects for insert
to authenticated
with check (bucket_id = 'achievements');

drop policy if exists "Authenticated users can update own achievement files" on storage.objects;
create policy "Authenticated users can update own achievement files"
on storage.objects for update
to authenticated
using (bucket_id = 'achievements' and owner_id = auth.uid()::text)
with check (bucket_id = 'achievements' and owner_id = auth.uid()::text);

drop policy if exists "Authenticated users can delete own achievement files" on storage.objects;
create policy "Authenticated users can delete own achievement files"
on storage.objects for delete
to authenticated
using (bucket_id = 'achievements' and owner_id = auth.uid()::text);

-- After creating your one admin account, turn OFF public signups in:
-- Authentication > Providers / Sign In settings (wording may vary).
-- Do not put a Supabase service_role/secret key in this website.
