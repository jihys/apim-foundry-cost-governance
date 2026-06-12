# 07: Operations Guidebook

**Labels:** ready-for-agent, AFK

## Parent

[PRD: APIM Foundry Cost Governance](../../prds/apim-foundry-cost-governance.md)

## What to build

Create 4 step-by-step operations guides in `docs/guidebook/`. Each guide is a standalone Markdown document targeting a specific operational task. Use screenshot placeholders (`<!-- screenshot: description -->`) where visual guidance would help — actual screenshots are captured manually later.

### Guide 1: `initial-setup.md`
Complete deployment from scratch: prerequisites (Azure CLI, Terraform, Python), `terraform.tfvars` configuration, `terraform init/plan/apply`, verifying resources in Azure Portal, obtaining APIM Subscription Keys.

### Guide 2: `add-project.md`
Two approaches for adding a new Foundry Project:
- **A) Terraform (recommended)**: Add project entry to `terraform.tfvars`, run `terraform apply`. Explain what resources are created automatically (Foundry Project, APIM Product, API, Subscription, User Group).
- **B) Azure Portal (manual)**: Step-by-step Portal instructions for creating each resource manually. Note that this approach requires manual consistency and is not recommended.

### Guide 3: `add-user.md`
Add a new team member to an existing Foundry Project: register user in APIM Developer Portal, assign to the correct User Group, share the APIM Subscription Key.

### Guide 4: `user-quickstart.md`
End-user getting started: receive APIM Subscription Key, configure `.env`, run the quickstart notebook, verify API calls work through APIM.

All guides should use CONTEXT.md domain vocabulary consistently (Foundry Project, APIM Subscription, etc.) and note the APIM SKU migration path (Developer → Standard v2) where relevant.

## Acceptance criteria

- [ ] `docs/guidebook/initial-setup.md` covers prerequisites, tfvars config, terraform deploy, post-deploy verification
- [ ] `docs/guidebook/add-project.md` covers both Terraform (A) and Portal manual (B) approaches, with Terraform marked as recommended
- [ ] `docs/guidebook/add-user.md` covers Developer Portal registration, User Group assignment, key sharing
- [ ] `docs/guidebook/user-quickstart.md` covers .env setup, notebook execution, call verification
- [ ] All guides use CONTEXT.md domain terms consistently (no bare "product", "subscription", "token" without qualifier)
- [ ] All guides include `<!-- screenshot: description -->` placeholders where visual steps would help
- [ ] Guides mention Developer SKU default and Standard v2 recommendation for production where relevant

## Blocked by

None — can start immediately (text-only deliverable, references deployed infra but does not require it).
