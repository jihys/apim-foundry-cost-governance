# 02: APIM Module with Subscription Key Routing

**Labels:** ready-for-agent, AFK

## Parent

[PRD: APIM Foundry Cost Governance](../../prds/apim-foundry-cost-governance.md)

## What to build

Create the APIM module that provisions an APIM Instance with per-project Products, APIs, and Subscriptions. The key behavior: end-users send requests to a single APIM endpoint with their APIM Subscription Key, and APIM automatically routes to the correct Foundry Endpoint.

The module creates:
- **APIM Instance** (Developer SKU by default, configurable via variable)
- **One APIM Product per Foundry Project** — named after the project but understood as implementation detail
- **One API per Foundry Project** — with backend URL set to the project's Foundry Endpoint, authenticated with the Project API Key (stored as APIM Named Value)
- **One APIM Subscription per Product** — the shared team key
- **One User Group per Product** — for Developer Portal self-service
- **Inbound policy**: Subscription key validation (default APIM behavior)
- **Backend policy**: Forward to Foundry Endpoint with Project API Key in authorization header

After this slice, a user with an APIM Subscription Key can call the APIM endpoint and have the request proxied to the correct Foundry Project.

## Acceptance criteria

- [ ] `infra/modules/apim/` creates an APIM Instance resource with SKU from variable (default Developer)
- [ ] One APIM Product is created per Foundry Project entry
- [ ] One API is created per project with `set-backend-service` policy pointing to the project's Foundry Endpoint
- [ ] Project API Keys are stored as APIM Named Values (secret)
- [ ] One APIM Subscription is created per Product
- [ ] One User Group is created per Product
- [ ] `infra/main.tf` wires the APIM module, passing Foundry module outputs (endpoints)
- [ ] `infra/outputs.tf` exposes the APIM gateway URL and per-project Subscription Key names
- [ ] `terraform validate` passes with both foundry and APIM modules wired

## Blocked by

- [01: Root Terraform Scaffold + Foundry Project Module](01-root-scaffold-foundry-module.md)
