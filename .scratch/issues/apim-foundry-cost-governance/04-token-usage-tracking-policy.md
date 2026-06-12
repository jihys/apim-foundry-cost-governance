# 04: Token Usage Tracking Outbound Policy

**Labels:** ready-for-agent, AFK

## Parent

[PRD: APIM Foundry Cost Governance](../../prds/apim-foundry-cost-governance.md)

## What to build

Add an APIM outbound policy that extracts token usage from Foundry model responses and writes them as App Insights custom dimensions. This is the core telemetry enrichment that enables per-project, per-model cost tracking.

The outbound policy must:
1. Parse the JSON response body from Foundry
2. Extract `usage.prompt_tokens`, `usage.completion_tokens`, `usage.total_tokens`
3. Extract the `model` field from the response
4. Emit these as App Insights custom dimensions along with the APIM subscription ID (already available in context)
5. Handle edge cases: non-JSON responses, missing `usage` field (some endpoints may not return it)

The policy is applied at the API level (all APIs in all Products), defined as part of the APIM module. The custom dimensions should be named: `prompt_tokens`, `completion_tokens`, `total_tokens`, `model_name`, `subscription_id`.

## Acceptance criteria

- [ ] APIM outbound policy XML extracts `usage.prompt_tokens`, `usage.completion_tokens`, `usage.total_tokens` from response body
- [ ] Policy extracts `model` field from response body
- [ ] Values are emitted to App Insights as custom dimensions via `emit-metric` or `trace` policy
- [ ] Custom dimensions include: `prompt_tokens`, `completion_tokens`, `total_tokens`, `model_name`, `subscription_id`
- [ ] Policy handles non-JSON or missing `usage` gracefully (no 500 errors)
- [ ] Policy is applied to all project APIs in the APIM module
- [ ] `terraform validate` passes with updated policy
- [ ] A sample App Insights KQL query is documented (comment or output) showing how to query token usage by project and model

## Blocked by

- [02: APIM Module with Subscription Key Routing](02-apim-module-subscription-routing.md)
- [03: Monitoring Module](03-monitoring-module.md)
