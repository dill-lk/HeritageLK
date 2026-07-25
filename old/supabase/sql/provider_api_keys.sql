-- Secure provider API key storage for server-side/edge access only
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.api_keys (
  -- Store provider names in lowercase (e.g. 'gemini', 'nvidia', 'openai')
  provider text primary key,
  api_key text not null,
  updated_at timestamptz not null default now()
);

alter table private.api_keys enable row level security;

drop policy if exists deny_select_anon_auth on private.api_keys;
create policy deny_select_anon_auth
on private.api_keys
for select
to anon, authenticated
using (false);

drop policy if exists deny_write_anon_auth on private.api_keys;
create policy deny_write_anon_auth
on private.api_keys
for all
to anon, authenticated
using (false)
with check (false);

-- Example inserts (replace values before running in production):
-- insert into private.api_keys (provider, api_key)
-- values ('gemini', 'YOUR_REAL_GEMINI_KEY')
-- on conflict (provider)
-- do update set api_key = excluded.api_key, updated_at = now();
--
-- insert into private.api_keys (provider, api_key)
-- values ('nvidia', 'YOUR_REAL_NVIDIA_KEY')
-- on conflict (provider)
-- do update set api_key = excluded.api_key, updated_at = now();
