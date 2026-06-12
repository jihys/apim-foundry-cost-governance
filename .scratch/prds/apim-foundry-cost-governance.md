# PRD: APIM Foundry Cost Governance

**Status:** ready-for-agent

## Problem Statement

조직 내 여러 팀이 Azure AI Foundry 모델을 사용할 때, 팀별 사용량 추적과 비용 분배가 불가능하다. 각 팀이 Foundry API Key를 직접 관리하면 키 노출 위험이 있고, 중앙화된 사용량 모니터링이 없어 예산 초과를 사전에 감지할 수 없다. 관리자는 프로젝트별/모델별 토큰 사용량과 예상 비용을 한눈에 파악할 수 있는 대시보드가 필요하다.

## Solution

Azure API Management를 AI Foundry 앞단에 배치하여, 팀별 **Foundry Project** 단위로 APIM Subscription Key를 발급한다. End-user는 단일 APIM 엔드포인트에 APIM Subscription Key만 전송하면, APIM이 해당 **Foundry Endpoint**로 자동 라우팅한다. APIM outbound policy에서 모델 응답의 `usage` 필드를 파싱하여 App Insights에 custom dimension으로 기록하고, App Insights Workbook 기반 **Cost Dashboard**에서 프로젝트별/모델별 토큰 사용량과 Azure Retail Prices API 기반 동적 예상 비용을 시각화한다. 전체 인프라는 Terraform으로 원클릭 배포된다.

## User Stories

1. As an **인프라 관리자**, I want to deploy the entire APIM + Foundry + monitoring stack with a single `terraform apply`, so that I can set up the governance environment without manual Azure Portal work.
2. As an **인프라 관리자**, I want to define Foundry Project names and model deployments in `terraform.tfvars`, so that I can add new projects by editing one config file and re-running Terraform.
3. As an **인프라 관리자**, I want each Foundry Project to have a default rate limit with per-project override capability, so that I can control resource consumption at the project level.
4. As an **end-user (개발자)**, I want to call AI models using a single APIM endpoint URL and my APIM Subscription Key, so that I don't need to know Foundry endpoint details or manage Foundry API keys.
5. As an **end-user (개발자)**, I want APIM to automatically route my request to the correct Foundry Project based on my Subscription Key, so that I can use the same endpoint for all models in my project.
6. As an **인프라 관리자**, I want APIM to extract `prompt_tokens`, `completion_tokens`, and `total_tokens` from every model response, so that token usage is automatically tracked without end-user changes.
7. As an **인프라 관리자**, I want token usage data recorded as App Insights custom dimensions with subscription-id and model name, so that I can query usage by project and model.
8. As an **인프라 관리자**, I want a Cost Dashboard (App Insights Workbook) deployed by Terraform, so that I can view project-level cost data immediately after deployment.
9. As an **인프라 관리자**, I want the Cost Dashboard to show: 프로젝트별 총 사용량, 일별 추이, 모델별 사용량, 예상 비용, so that I can make budget decisions with current data.
10. As an **인프라 관리자**, I want the Cost Dashboard to fetch model pricing dynamically from Azure Retail Prices API, so that pricing stays accurate without manual updates.
11. As an **end-user (개발자)**, I want a quickstart notebook comparing direct OpenAI SDK calls vs APIM-proxied calls, so that I can verify my setup works and understand the APIM flow.
12. As an **인프라 관리자**, I want a step-by-step initial setup guide, so that I can deploy the full environment from scratch.
13. As an **인프라 관리자**, I want an add-project guide with both Terraform (recommended) and Azure Portal manual approaches, so that I can choose the method appropriate for my situation.
14. As an **인프라 관리자**, I want an add-user guide, so that I can onboard new team members to their Foundry Project via APIM User Group.
15. As an **end-user (개발자)**, I want a user quickstart guide, so that I can start calling models through APIM within minutes.
16. As an **인프라 관리자**, I want the networking module to be a placeholder for future Private Endpoint expansion, so that the architecture is ready for production hardening.
17. As an **인프라 관리자**, I want guides to include screenshot placeholders (`<!-- screenshot: description -->`), so that I can fill them in with actual environment captures later.
18. As an **인프라 관리자**, I want the option to add `x-user-id` custom header tracking in the future, so that per-user token tracking is possible when needed.

## Implementation Decisions

### Deployment & Configuration

- **IaC tool**: Terraform for all Azure resources (APIM, Foundry Projects, App Insights, Log Analytics, Workbook).
- **Configuration split**: `terraform.tfvars` for infrastructure settings (project names, models, rate limits); `.env` for runtime test settings (APIM endpoint, Subscription Key).
- **tfvars structure**: List of projects, each with `name` + `models`. Rate limit has a global default with per-project override option.
- **APIM SKU**: Developer tier by default. Documentation recommends Standard v2 for production.

### APIM Architecture

- **1 Foundry Project = 1 APIM Product**: APIM Product is an implementation detail; domain conversations use "Foundry Project" only.
- **1 APIM Subscription per Foundry Project**: Team members share the key.
- **Routing**: Subscription Key-based automatic routing. End-user sends requests to a single APIM endpoint; APIM resolves the target Foundry Endpoint via the Subscription's Product binding.
- **User management**: APIM User Group for self-service via Developer Portal.

### Foundry

- **Endpoint**: Foundry Project-level direct endpoints (not Hub-level legacy endpoints).
- **Provisioning**: `azapi` Terraform provider for Foundry Project creation.

### Monitoring & Cost

- **Token tracking**: APIM outbound policy parses `usage` field from Foundry response → writes `prompt_tokens`, `completion_tokens`, `total_tokens`, `model`, `subscription-id` as App Insights custom dimensions.
- **Cost Dashboard**: App Insights Workbook deployed via Terraform. Uses Azure Retail Prices API (`prices.azure.com`) for dynamic per-model pricing — no manual price table maintenance.
- **Dashboard metrics**: 프로젝트별 총 사용량, 일별 추이, 모델별 사용량, 예상 비용.

### Networking

- Public endpoints for initial deployment. Private Endpoint module placeholder for production expansion.

### Documentation

- 4 guides in `docs/guidebook/`: initial-setup, add-project (A: Terraform + B: Portal manual), add-user, user-quickstart.
- Screenshot placeholders: `<!-- screenshot: description -->`.

### Modules

| Module | Responsibility |
|---|---|
| `infra/modules/foundry/` | Foundry Project creation via azapi provider |
| `infra/modules/apim/` | APIM instance, Products, APIs, Subscriptions, outbound token-tracking policy |
| `infra/modules/monitoring/` | App Insights, Log Analytics, Cost Dashboard Workbook |
| `infra/modules/networking/` | Empty placeholder for Private Endpoint expansion |
| `infra/` (root) | main.tf, variables.tf, outputs.tf, terraform.tfvars.example |
| `notebooks/` | apim-quickstart.ipynb |
| `docs/guidebook/` | 4 operations guides |

## Testing Decisions

- **Terraform validation**: Each module should pass `terraform validate` and `terraform plan` independently where feasible.
- **Policy testing**: Token extraction outbound policy should be tested against sample Foundry response payloads to verify correct custom dimension mapping.
- **Notebook**: The quickstart notebook serves as an integration smoke test — direct Foundry call vs APIM-proxied call should both return valid model responses.
- **Good tests**: Test observable infrastructure outputs (resource existence, policy behavior) not internal Terraform implementation details. Use `terraform plan` output assertions where applicable.

## Out of Scope

- Per-user token tracking (`x-user-id` custom header) — documented as extension path, not implemented initially.
- Private Endpoint / VNet integration — networking module is a placeholder only.
- APIM Developer Portal customization beyond default User Group setup.
- Automated screenshot capture for guides (manual capture required).
- CI/CD pipeline for Terraform deployment.
- Multi-region or disaster recovery configuration.
- Azure Policy / compliance automation.
- Budget alerts or automated cost management actions (Cost Dashboard is read-only visualization).

## Further Notes

- **APIM SKU migration path**: Developer → Standard v2 for production. Guide should mention SKU change implications.
- **Ambiguity guards** (from CONTEXT.md): Always distinguish "APIM Subscription" vs "Azure Subscription", "Project API Key" vs "APIM Subscription Key", "Token Usage" (model tokens) vs authentication tokens.
- **azapi provider**: Required because the standard `azurerm` provider does not yet fully support AI Foundry Project resources.
- **Retail Prices API**: Called directly from within the App Insights Workbook — no intermediate service or scheduled job needed. Once the Workbook is deployed, pricing stays current automatically.
