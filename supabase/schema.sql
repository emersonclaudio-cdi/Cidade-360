-- Cidade 360: schema multi-tenant para Supabase/PostgreSQL
create extension if not exists pgcrypto;
create extension if not exists postgis;

create type public.occurrence_status as enum ('detected','validating','confirmed','forwarded','in_progress','resolved','closed','not_confirmed');
create type public.priority_level as enum ('low','medium','high','critical');

create table public.municipalities (id uuid primary key default gen_random_uuid(), name text not null, state char(2) not null, ibge_code text unique, created_at timestamptz default now());
create table public.departments (id uuid primary key default gen_random_uuid(), municipality_id uuid not null references public.municipalities on delete cascade, name text not null, slug text not null, sla_hours int default 72, unique(municipality_id,slug));
create table public.neighborhoods (id uuid primary key default gen_random_uuid(), municipality_id uuid not null references public.municipalities on delete cascade, name text not null, centroid geography(point,4326), boundary geometry(multipolygon,4326), unique(municipality_id,name));
create table public.profiles (id uuid primary key references auth.users on delete cascade, full_name text, role text not null default 'operator' check(role in ('platform_admin','municipal_admin','manager','operator','viewer')), created_at timestamptz default now());
create table public.memberships (user_id uuid references public.profiles on delete cascade, municipality_id uuid references public.municipalities on delete cascade, department_id uuid references public.departments on delete set null, primary key(user_id,municipality_id));
create table public.sources (id uuid primary key default gen_random_uuid(), municipality_id uuid not null references public.municipalities on delete cascade, name text not null, source_type text not null, active boolean default true, config jsonb default '{}'::jsonb);
create table public.manifestations (id uuid primary key default gen_random_uuid(), municipality_id uuid not null references public.municipalities on delete cascade, source_id uuid references public.sources on delete set null, external_id text, raw_text text not null, captured_at timestamptz not null default now(), neighborhood_id uuid references public.neighborhoods on delete set null, location geography(point,4326), category text, subcategory text, intent text, sentiment text, severity numeric(4,3), confidence numeric(4,3), personal_data_redacted boolean default false, metadata jsonb default '{}'::jsonb, unique(source_id,external_id));
create table public.occurrences (id uuid primary key default gen_random_uuid(), protocol text unique not null, municipality_id uuid not null references public.municipalities on delete cascade, neighborhood_id uuid references public.neighborhoods on delete set null, department_id uuid references public.departments on delete set null, title text not null, summary text, category text not null, location geography(point,4326), status public.occurrence_status default 'detected', priority public.priority_level default 'medium', confirmed boolean default false, due_at timestamptz, resolved_at timestamptz, created_at timestamptz default now(), updated_at timestamptz default now());
create table public.occurrence_manifestations (occurrence_id uuid references public.occurrences on delete cascade, manifestation_id uuid references public.manifestations on delete cascade, similarity numeric(4,3), primary key(occurrence_id,manifestation_id));
create table public.occurrence_events (id uuid primary key default gen_random_uuid(), occurrence_id uuid not null references public.occurrences on delete cascade, actor_id uuid references public.profiles on delete set null, event_type text not null, from_status public.occurrence_status, to_status public.occurrence_status, note text, metadata jsonb default '{}'::jsonb, created_at timestamptz default now());
create table public.ai_alerts (id uuid primary key default gen_random_uuid(), municipality_id uuid not null references public.municipalities on delete cascade, neighborhood_id uuid references public.neighborhoods on delete set null, department_id uuid references public.departments on delete set null, alert_type text not null, title text not null, summary text not null, score numeric(5,2), evidence jsonb default '{}'::jsonb, acknowledged_at timestamptz, created_at timestamptz default now());
create index manifestations_municipality_time_idx on public.manifestations(municipality_id,captured_at desc);
create index occurrences_municipality_status_idx on public.occurrences(municipality_id,status,created_at desc);
create index manifestations_location_gix on public.manifestations using gist(location);
create index occurrences_location_gix on public.occurrences using gist(location);
create index neighborhoods_boundary_gix on public.neighborhoods using gist(boundary);

alter table public.municipalities enable row level security; alter table public.departments enable row level security; alter table public.neighborhoods enable row level security; alter table public.sources enable row level security; alter table public.manifestations enable row level security; alter table public.occurrences enable row level security; alter table public.occurrence_manifestations enable row level security; alter table public.occurrence_events enable row level security; alter table public.ai_alerts enable row level security;

create or replace function public.has_municipality_access(mid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from memberships where user_id=auth.uid() and municipality_id=mid) $$;
create policy municipality_members_read on public.municipalities for select using(public.has_municipality_access(id));
create policy departments_members_read on public.departments for select using(public.has_municipality_access(municipality_id));
create policy neighborhoods_members_read on public.neighborhoods for select using(public.has_municipality_access(municipality_id));
create policy sources_members_read on public.sources for select using(public.has_municipality_access(municipality_id));
create policy manifestations_members_read on public.manifestations for select using(public.has_municipality_access(municipality_id));
create policy occurrences_members_read on public.occurrences for select using(public.has_municipality_access(municipality_id));
create policy alerts_members_read on public.ai_alerts for select using(public.has_municipality_access(municipality_id));

-- Escritas de produção devem ocorrer por RPCs/Edge Functions com validação de papel, não por acesso anônimo do cliente.
