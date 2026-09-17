# Pipeline de IA — Cidade 360

## Objetivo
Converter manifestações legitimamente acessíveis à gestão em sinais operacionais, sem presumir que uma manifestação seja um fato confirmado.

## Etapas
1. Ingestão por conectores autorizados e webhooks.
2. Normalização, remoção/minimização de PII e prevenção de duplicidade por `source_id + external_id`.
3. Classificação: categoria, subcategoria, intenção, sentimento contextual, severidade e confiança.
4. Extração territorial: município, bairro, logradouro/unidade pública e coordenada somente quando houver evidência suficiente.
5. Deduplicação semântica: associar manifestações à mesma ocorrência provável por similaridade textual + proximidade espacial + janela temporal + categoria.
6. Triagem humana quando confiança/localização forem insuficientes ou quando severidade for alta.
7. Geração de ocorrência. Status inicial `detected`; somente validação operacional pode marcar `confirmed`.
8. Priorização operacional por gravidade, recorrência, crescimento, dispersão territorial, SLA e criticidade do serviço.
9. Alertas de tendência baseados em variação contra baseline histórico.
10. Encaminhamento à secretaria e trilha de auditoria.

## Contrato de saída do classificador
```json
{
  "category": "Saúde",
  "subcategory": "Medicamentos",
  "intent": "reclamacao",
  "sentiment": "negativo",
  "severity": 0.78,
  "confidence": 0.91,
  "location": {"neighborhood":"Pequi","place":"UBS","lat":null,"lng":null,"confidence":0.72},
  "summary": "Relato de indisponibilidade de medicamentos em unidade de saúde.",
  "needs_human_review": true,
  "reason": "Unidade específica não identificada com confiança suficiente."
}
```

## Regras obrigatórias
- Nunca inferir endereço residencial ou identidade do autor.
- Não armazenar PII desnecessária.
- Não classificar manifestação como ocorrência confirmada automaticamente.
- Guardar evidência, confiança, versão do modelo/prompt e horário de processamento.
- Não usar o sistema para inferir preferência política individual ou criar perfis políticos de cidadãos.
- Recomendações da IA devem ser operacionais (validar estoque, verificar iluminação, revisar SLA), não partidárias.

## Índice de Pressão Territorial (IPT)
Indicador operacional de 0–100, calculado com componentes auditáveis: volume normalizado, aceleração versus baseline, severidade, recorrência e atraso/SLA. O painel deve sempre permitir abrir os componentes do índice; não tratar IPT como aprovação/rejeição política da gestão.
