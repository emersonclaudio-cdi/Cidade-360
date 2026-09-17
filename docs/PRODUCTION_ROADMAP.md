# Roadmap de produção

## Fase 1 — Fundação (em andamento)
- UI responsiva dos módulos executivos
- Modelo multi-tenant
- PostGIS e RLS
- Pipeline de IA auditável
- Proteção de segredos

## Fase 2 — Backend real
- Criar projeto Supabase
- Aplicar `supabase/schema.sql`
- Configurar Auth, convites e perfis
- Implementar RPCs/Edge Functions de escrita com RBAC
- Seed de município/bairros/secretarias
- CRUD de ocorrências e histórico

## Fase 3 — Mapa Vivo
- Provedor cartográfico
- GeoJSON oficial de bairros
- clustering de pins, heatmap e drill-down
- geocodificação controlada e score de confiança

## Fase 4 — Escuta e n8n
- Webhooks de ingestão
- conectores autorizados por fonte
- fila, idempotência, retry e dead-letter
- normalização e minimização de PII
- classificação, deduplicação e alertas

## Fase 5 — Operação
- SLAs por secretaria/categoria
- notificações e escalonamento
- anexos/evidências
- auditoria de mudanças
- exportação de briefing executivo

## Fase 6 — Produção
- domínio, HTTPS e deploy
- observabilidade e alertas
- backups e restauração testada
- política de retenção e LGPD
- testes de carga, segurança e RLS
- homologação com usuários municipais

## Critério de “pronto de verdade”
O produto só é considerado pronto para operação real após backend provisionado, autenticação/RLS testadas, mapa e dados oficiais configurados, fontes autorizadas integradas, pipeline de IA monitorado, política LGPD definida, backup/restauração validados e homologação municipal. Nunca usar dados demonstrativos como se fossem fatos reais.
