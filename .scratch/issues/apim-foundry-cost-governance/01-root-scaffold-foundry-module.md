# 01: Root Terraform Scaffold + Foundry Project Module

**Labels:** ready-for-agent, AFK

## Parent

[PRD: APIM Foundry Cost Governance](../../prds/apim-foundry-cost-governance.md)

## What to build

Create the root Terraform orchestration structure and the Foundry Project module. This is the foundation slice — it establishes the `terraform.tfvars` structure, root variable definitions, and the first deployable module.

The **root level** (`infra/`) needs `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, and `terraform.tfvars.example`. The tfvars example should demonstrate the project list structure: each project has a `name` and a `models` list. A global `default_rate_limit` with per-project override is defined in variables.

The **foundry module** (`infra/modules/foundry/`) provisions Foundry Projects using the `azapi` Terraform provider. Each project entry from tfvars becomes a Foundry Project resource with its own Foundry Endpoint. The module outputs project names and endpoint URLs for downstream modules.

The **networking module** (`infra/modules/networking/`) is created as an empty placeholder with a README explaining its future purpose (Private Endpoint expansion).

After this slice, `terraform init && terraform validate` should succeed, and `terraform plan` should show Foundry Project resources.

## Acceptance criteria

- [ ] `infra/providers.tf` declares `azurerm` and `azapi` providers with required versions
- [ ] `infra/variables.tf` defines: `resource_group_name`, `location`, `foundry_hub_name`, `projects` (list of objects with `name`, `models`, optional `rate_limit`), `default_rate_limit`, `apim_sku` (default `"Developer"`)
- [ ] `infra/terraform.tfvars.example` contains a sample configuration with 2+ projects, each with `name` and `models`
- [ ] `infra/modules/foundry/` creates Foundry Project resources using `azapi_resource`
- [ ] Foundry module outputs `project_endpoints` map (project name → endpoint URL)
- [ ] `infra/modules/networking/` exists with a `README.md` explaining placeholder status
- [ ] `infra/main.tf` calls the foundry module and passes project list from variables
- [ ] `infra/outputs.tf` exposes foundry project endpoints
- [ ] `terraform validate` passes from `infra/` directory

## Blocked by

None — can start immediately.
