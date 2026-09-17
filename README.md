# Cidade 360

**Inteligência para ouvir, entender e resolver.**

MVP de uma plataforma SaaS multi-município para escuta pública, inteligência territorial e gestão operacional de ocorrências municipais.

## MVP atual

- Sala do Prefeito com KPIs executivos
- Mapa Vivo com pressão por bairro e pins
- Escuta 360 para manifestações classificadas
- Central de Ocorrências
- Painéis por Secretarias
- Inteligência & Relatórios com alertas e tendências
- Dados demonstrativos de Eunápolis/BA
- Layout responsivo

## Próxima arquitetura

Frontend React + TypeScript; persistência Supabase/PostgreSQL + PostGIS; automações n8n; provedor de mapas; camada de IA para classificação, resumo, deduplicação, geolocalização semântica e detecção de tendências.

## Princípios de dados

O sistema deve distinguir manifestação pública de ocorrência confirmada, separar volume de comentários de problemas físicos distintos, adotar minimização de dados pessoais e controles de acesso, e respeitar LGPD e termos/APIs das fontes integradas.

## Executar

```bash
npm install
npm run dev
```
