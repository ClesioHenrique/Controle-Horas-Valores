-- Rode UMA vez no Supabase: SQL Editor > New query > colar > Run.
-- Projeto: https://henuatkfajesczzjdilb.supabase.co (mesmo do Painel de Faturamento).
-- Guarda os dados do Relatorio_Horas_Valores.html numa unica linha (id = 1).

create table if not exists public.relatorio_horas_snapshot (
  id          int primary key,
  payload     jsonb       not null,
  file_name   text,
  updated_by  text,
  updated_at  timestamptz not null default now()
);

alter table public.relatorio_horas_snapshot enable row level security;

-- qualquer pessoa que abre o relatorio le (chave anon)
drop policy if exists "relatorio_snapshot_leitura" on public.relatorio_horas_snapshot;
create policy "relatorio_snapshot_leitura"
  on public.relatorio_horas_snapshot for select
  using (true);

-- so usuario logado publica
drop policy if exists "relatorio_snapshot_insert" on public.relatorio_horas_snapshot;
create policy "relatorio_snapshot_insert"
  on public.relatorio_horas_snapshot for insert
  to authenticated
  with check (id = 1);

drop policy if exists "relatorio_snapshot_update" on public.relatorio_horas_snapshot;
create policy "relatorio_snapshot_update"
  on public.relatorio_horas_snapshot for update
  to authenticated
  using (id = 1)
  with check (id = 1);
