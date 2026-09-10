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
  revoked_at timestamptz,
  unique(parent_id, policy_version)
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
-- Parent API verifies current Google Play state on purchase, restore and refresh.
create table public.purchase_tokens (
 token_hash text primary key check (token_hash ~ '^[a-f0-9]{64}$'),
 parent_id uuid not null references public.parent_accounts(id) on delete cascade,
 ciphertext text not null,
 product_id text not null,
 verified_at timestamptz not null default now()
);
create index purchase_parent_idx on public.purchase_tokens(parent_id);
alter table public.purchase_tokens enable row level security;
revoke all on public.purchase_tokens from anon, authenticated;
grant all on public.purchase_tokens to service_role;
-- Security invoker: caller must already have service privileges. No client RPC.
create function public.parent_session_valid(p_parent uuid, p_session uuid)
returns boolean language sql stable security invoker set search_path = '' as $$
 select exists(select 1 from auth.sessions where user_id=p_parent and id=p_session)
$$;
revoke all on function public.parent_session_valid(uuid,uuid) from public, anon, authenticated;
grant execute on function public.parent_session_valid(uuid,uuid) to service_role;
create function public.retain_verified_purchase(p_parent uuid, p_hash text, p_cipher text, p_product text, p_status text, p_expiry timestamptz)
returns void language plpgsql security invoker set search_path = '' as $$
begin
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_hash,0));
 if exists(select 1 from public.purchase_tokens where token_hash=p_hash and parent_id<>p_parent) then raise exception 'Receipt already belongs to another account'; end if;
 insert into public.purchase_tokens(token_hash,parent_id,ciphertext,product_id) values(p_hash,p_parent,p_cipher,p_product)
 on conflict(token_hash) do update set ciphertext=excluded.ciphertext, verified_at=now();
 insert into public.entitlements(parent_id,product_id,status,expires_at,store) values(p_parent,p_product,p_status,p_expiry,'google')
 on conflict(parent_id) do update set product_id=excluded.product_id,status=excluded.status,expires_at=excluded.expires_at,verified_at=now();
end
$$;
revoke all on function public.retain_verified_purchase(uuid,text,text,text,text,timestamptz) from public, anon, authenticated;
grant execute on function public.retain_verified_purchase(uuid,text,text,text,text,timestamptz) to service_role;
commit;
