# Add Project Guide

> 🇰🇷 [한국어 버전](../kr/02-add-project.md)

This guide explains how to add a new Foundry Project (team). There are two methods; **Method A (Terraform re-apply)** is recommended.

---

## Method A: Terraform Re-Apply (Recommended)

Terraform preserves existing resources and adds only the new Foundry Project.

### Step 1: Add the New Project to `terraform.tfvars`

Append the new project name to the `foundry_projects` list in `infra/terraform.tfvars`:

```hcl
foundry_projects = ["catalog-project", "image-project", "search-project"]  # new project added
```

### Step 2: Review the Changes

```bash
cd infra
terraform plan
```

The following new resources will be created:

- `azapi_resource.project["search-project"]` — New Foundry Project (child resource of the Foundry Resource)
- `azurerm_api_management_product.project["search-project"]` — APIM Product
- `azurerm_api_management_subscription.project["search-project"]` — Service Key
- `azurerm_api_management_group.project["search-project"]` — User Group

Verify that the existing `catalog-project` and `image-project` remain unchanged.

<!-- screenshot: terraform plan output showing only new resources being added -->

### Step 3: Apply the Deployment

```bash
terraform apply
```

### Step 4: Verify the New Foundry Endpoint

```bash
terraform output foundry_project_endpoints
```

Confirm that the new project's Foundry Endpoint has been added.

> **Note:** Terraform creates the APIM Product, API, User Group, and **Service Key** (`{project}-service-key`) for the new Foundry Project together. The Service Key is for system automation such as CI/CD pipelines — it should not be used by individuals.
>
> Developers obtain their own **Personal Key** via self-service on the Developer Portal. See the [Add User Guide](03-add-user.md) for details.
>
> To check the Service Key:
> ```bash
> terraform output -json apim_subscription_keys
> ```

---

## Method B: Manual Addition via Azure Portal

> ⚠️ **Warning:** Adding resources manually through the Portal causes drift from the Terraform state. You must synchronize via `terraform import`, or conflicts will occur on the next `terraform apply`. **Method A is recommended.**

Even when manual addition is necessary, the safest approach is to add the project name to `terraform.tfvars` and run `terraform apply`. If you must create resources directly in the Portal, you need to configure all of the following manually:

1. **Create the Foundry Project:** Add a project under the Azure AI Foundry Resource.
2. **Create the APIM Product:** APIM Instance > Products > + Add. Set the Product name to match the Foundry Project name.
3. **Configure the APIM Backend:** APIs > + Add API > select HTTP. Enter the new Foundry Endpoint URL as the backend URL.
4. **Create the User Group:** APIM Instance > Groups > + Add. Name: `{project}-users`
5. **Link Product to Group:** In Product settings, go to Access control > add the User Group you created.
6. **Create the Service Key (for CI/CD):** APIM Instance > Subscriptions > + Add subscription. Name: `{project}-service-key`, scope: the Product you created.

> **Note:** When adding manually, the Product must be configured correctly for Personal Key issuance via the Developer Portal (`subscription_required = true`, `subscriptions_limit = 1`, `approval_required = false`).

### Terraform State Synchronization

Import manually added resources into the Terraform state:

```bash
terraform import 'module.foundry.azapi_resource.project["search-project"]' \
  /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-name>/projects/search-project
```

> ⚠️ If you do not import all manually created resources, conflicts will occur on the next `terraform apply`.

---

## Comparison

| Criteria | Method A (Terraform) | Method B (Portal Manual) |
|----------|---------------------|--------------------------|
| Time required | ~5 min | ~20 min |
| Drift risk | None | High |
| Reproducibility | Fully reproducible | Requires manual documentation |
| APIM integration | Automatic | Manual configuration required |
| Recommendation | ✅ Recommended | ⚠️ Emergency use only |
