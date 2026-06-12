# ADR-001: AI Foundry Resource Model

## Status

Accepted

## Context

The initial design provisioned one `Microsoft.CognitiveServices/accounts` resource with `kind=OpenAI` per team (e.g., catalog, image). Each account carried its own model deployments, API keys, and endpoint.

This approach had several problems:

1. **No AI Foundry Portal access.** Resources with `kind=OpenAI` do not appear in the AI Foundry Portal, preventing teams from using the portal's experimentation, evaluation, and prompt-flow features.
2. **Duplicated model deployments.** The same model (e.g., gpt-4o) was deployed separately in every team's account, increasing quota consumption and management overhead.
3. **Quota fragmentation.** Each account consumed its own regional quota allocation. Sharing unused capacity across teams was impossible without manual reallocation.
4. **Inconsistent lifecycle.** Adding a new model required updating every team's deployment list and re-running Terraform for each account.

## Decision

Replace per-team `kind=OpenAI` accounts with a single shared Foundry resource and per-team child projects:

```
Foundry Resource (kind=AIServices, shared)
├── Project: catalog   (child resource, RBAC boundary)
├── Project: image     (child resource, RBAC boundary)
├── gpt-4o deployment  (GlobalStandard, shared)
├── gpt-5.4 deployment (GlobalStandard, shared)
└── gpt-5.2 deployment (GlobalStandard, shared)
```

Specifically:

- **One `Microsoft.CognitiveServices/accounts` resource** with `kind=AIServices` and SKU `S0` serves as the shared Foundry resource. It houses all model deployments and provides the resource-level API key.
- **Child `Microsoft.CognitiveServices/accounts/projects` resources** (one per team) provide isolated RBAC boundaries, dedicated endpoints, and AI Foundry Portal project views.
- **Model deployments** are defined at the Foundry resource level using `GlobalStandard` SKU, making all deployed models available to every project.
- **API key** is resource-level (identical for all projects). Per-team access isolation is enforced through APIM Subscription keys and routing policies.
- **No Storage Account or Key Vault** is required; the Foundry resource uses managed storage.

The Terraform implementation uses `azapi_resource` (not `azurerm`) because the `accounts/projects` child resource type and `kind=AIServices` are not yet fully supported in the AzureRM provider.

## Consequences

### Positive

- **AI Foundry Portal access.** Teams can use the Foundry Portal to experiment with prompts, run evaluations, and manage prompt flows within their project scope.
- **Shared model deployments.** A model is deployed once and available to all projects, reducing quota consumption and simplifying lifecycle management.
- **Unified quota pool.** All projects draw from a single regional quota allocation, enabling natural load balancing across teams.
- **Simpler Terraform.** Adding a new team requires only a project name in the variable list; model deployments are managed independently of team membership.
- **Cost visibility preserved.** APIM Subscription-based routing still enables per-project token tracking via App Insights telemetry.

### Negative

- **Blast radius.** A misconfiguration on the shared Foundry resource (e.g., accidental deletion, SKU change) affects all teams simultaneously.
- **Shared API key.** The resource-level API key is the same for all projects. If leaked, it grants access to all deployments. Mitigation: the key is only stored in APIM backend configuration; end-users never see it.
- **AzureRM provider gap.** Using `azapi_resource` adds complexity and requires tracking Azure API versions manually. This will be revisited when AzureRM adds native support for `kind=AIServices` and child projects.
- **No per-project deployment isolation.** All projects share the same model deployments and their rate limits. Per-team rate limiting must be enforced at the APIM layer.
