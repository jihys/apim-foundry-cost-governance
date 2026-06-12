# 03: Monitoring Module (App Insights + Log Analytics)

**Labels:** ready-for-agent, AFK

## Parent

[PRD: APIM Foundry Cost Governance](../../prds/apim-foundry-cost-governance.md)

## What to build

Create the monitoring module that provisions App Insights and Log Analytics Workspace, and connects APIM to App Insights as its logger. This establishes the telemetry pipeline that later slices will feed token data into.

The module creates:
- **Log Analytics Workspace** — backing store for App Insights
- **Application Insights** resource — connected to the Log Analytics Workspace
- **APIM Logger** — connects the APIM Instance to App Insights (requires APIM resource ID as input)
- **APIM Diagnostic** — configures what APIM logs to App Insights (request/response headers, timing)

After this slice, all APIM requests are logged to App Insights with standard dimensions. Custom token dimensions come in the next slice.

## Acceptance criteria

- [ ] `infra/modules/monitoring/` creates a Log Analytics Workspace
- [ ] Module creates an Application Insights resource linked to the Log Analytics Workspace
- [ ] Module creates an APIM Logger resource connecting APIM to App Insights via instrumentation key
- [ ] Module creates an APIM Diagnostic setting to log requests to App Insights
- [ ] Module outputs `app_insights_instrumentation_key`, `app_insights_id`, `log_analytics_workspace_id`
- [ ] `infra/main.tf` wires the monitoring module, passing APIM instance details
- [ ] `terraform validate` passes with foundry, APIM, and monitoring modules wired

## Blocked by

- [01: Root Terraform Scaffold + Foundry Project Module](01-root-scaffold-foundry-module.md)
