# 05: Cost Dashboard Workbook

**Labels:** ready-for-agent, AFK

## Parent

[PRD: APIM Foundry Cost Governance](../../prds/apim-foundry-cost-governance.md)

## What to build

Create an App Insights Workbook deployed via Terraform that visualizes per-project, per-model token usage and estimated costs. The Workbook fetches dynamic model pricing from Azure Retail Prices API (`prices.azure.com`) — no manual price tables.

The Workbook should contain these panels:
1. **프로젝트별 총 사용량** — Total token usage per Foundry Project (bar chart)
2. **일별 추이** — Daily token usage trend (time series line chart)
3. **모델별 사용량** — Token usage breakdown by model (stacked bar or table)
4. **예상 비용** — Estimated cost per project using Retail Prices API unit prices × token counts

The KQL queries source data from App Insights custom dimensions (`prompt_tokens`, `completion_tokens`, `total_tokens`, `model_name`, `subscription_id`) written by the outbound policy.

The Retail Prices API integration uses the Workbook's built-in web data source to call `https://prices.azure.com/api/retail/prices` with filters for the relevant model SKUs, then joins pricing data with usage data.

## Acceptance criteria

- [ ] `infra/modules/monitoring/` includes a Terraform resource for an App Insights Workbook (JSON template)
- [ ] Workbook has a panel showing total token usage per project (grouped by `subscription_id`)
- [ ] Workbook has a panel showing daily usage trend (time series)
- [ ] Workbook has a panel showing per-model token usage breakdown
- [ ] Workbook has a panel showing estimated cost using Azure Retail Prices API for dynamic pricing
- [ ] Workbook is automatically deployed with `terraform apply` — no manual Azure Portal setup
- [ ] KQL queries reference the correct custom dimension names from the outbound policy
- [ ] `terraform validate` passes with the Workbook resource

## Blocked by

- [03: Monitoring Module](03-monitoring-module.md)
- [04: Token Usage Tracking Outbound Policy](04-token-usage-tracking-policy.md)
