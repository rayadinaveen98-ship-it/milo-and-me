-- CANDIDATE SCHEMA. Not deployed or database-tested in this environment.
-- With a configured local Supabase project, generate a migration using the CLI,
-- apply this candidate locally, run ownership/privilege tests, then promote it.
-- No child profiles, pictures, pet memory or tap history are stored remotely.
begin;
create table public.parent_accounts (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table public.consent_records (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.parent_accounts(id) on delete cascade,
  policy_version text not null,
  verification_method text not null,
  granted_at timestamptz not null default now(),
  revoked_at timestamptz
);
create index consent_parent_idx on public.consent_records(parent_id);
create table public.entitlements (
  parent_id uuid primary key references public.parent_accounts(id) on delete cascade,
  product_id text not null,
  status text not null check (status in ('active','expired','revoked')),
  expires_at timestamptz not null,
  store text not null check (store in ('google','apple')),
  verified_at timestamptz not null default now()
);
create table public.content_packs (
  id text primary key check (id ~ '^[a-z0-9][a-z0-9_-]{0,63}$'),
  title text not null,
  version integer not null check (version>0),
  schema_version integer not null default 1,
  download_url text not null check (download_url like 'https://%'),
  sha256 text not null check (sha256 ~ '^[a-f0-9]{64}$'),
  price_tier text not null check (price_tier in ('free','premium')),
  published boolean not null default false
);
create table public.backup_metadata (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid not null references public.parent_accounts(id) on delete cascade,
  storage_key text not null unique,
  encrypted_sha256 text not null,
  encryption_version integer not null,
  created_at timestamptz not null default now()
);
create index backup_parent_idx on public.backup_metadata(parent_id);

alter table public.parent_accounts enable row level security;
alter table public.consent_records enable row level security;
alter table public.entitlements enable row level security;
alter table public.content_packs enable row level security;
alter table public.backup_metadata enable row level security;
revoke all on public.parent_accounts, public.consent_records, public.entitlements, public.content_packs, public.backup_metadata from anon, authenticated;
grant select on public.parent_accounts, public.consent_records, public.entitlements, public.content_packs, public.backup_metadata to authenticated;
grant all on public.parent_accounts, public.consent_records, public.entitlements, public.content_packs, public.backup_metadata to service_role;
create policy parent_reads_self on public.parent_accounts for select to authenticated
 using ((select auth.uid())=id);
create policy parent_reads_consent on public.consent_records for select to authenticated
 using ((select auth.uid())=parent_id);
create policy parent_reads_entitlement on public.entitlements for select to authenticated
 using ((select auth.uid())=parent_id);
create policy parent_reads_published_packs on public.content_packs for select to authenticated
 using (published=true);
create policy parent_reads_backup_metadata on public.backup_metadata for select to authenticated
 using ((select auth.uid())=parent_id);
-- All writes require server-owned functions with verified parent identity.
-- A client cannot grant itself a subscription or fabricate verified consent.
-- Do not deploy a purchase endpoint before store receipt verification and
-- idempotent, authenticated store webhook handling have been implemented.
commit;
