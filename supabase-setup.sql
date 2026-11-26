-- Run this once in Supabase: SQL Editor > New query > paste > Run
create table if not exists public.media(
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  kind text not null check (kind in ('photo','video')),
  path text not null,
  status text not null default 'pending' check (status in ('pending','approved'))
);
alter table public.media enable row level security;
create policy "guests can add pending" on public.media for insert to anon with check (status='pending');
create policy "anyone can see approved" on public.media for select to anon using (status='approved');
create policy "admin full access" on public.media for all to authenticated using (true) with check (true);

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('party','party',true,31457280,array['image/jpeg','image/png','image/webp','video/mp4','video/webm','video/quicktime'])
on conflict (id) do update set public=true,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
create policy "guests can upload" on storage.objects for insert to anon with check (bucket_id='party');
create policy "admin manages files" on storage.objects for all to authenticated using (bucket_id='party') with check (bucket_id='party');
