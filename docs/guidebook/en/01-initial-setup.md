# Initial Setup Guide

> 🇰🇷 [한국어 버전](../kr/01-initial-setup.md)

This guide walks you through deploying the APIM Foundry Cost Governance infrastructure from scratch.

## Prerequisites

| Tool | Minimum Version | Verify |
|------|-----------------|--------|
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | 2.50+ | `az --version` |
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.5+ | `terraform --version` |
| [Python](https://www.python.org/downloads/) | 3.10+ | `python --version` |

You must be logged in to Azure CLI:

```bash
az login
az account set --subscription "<Azure Subscription ID>"

# Verify the active subscription
az account show --query "{name:name, id:id}" -o table
```

<!-- screenshot: Azure CLI login success screen -->

### Register Azure Resource Providers

The following Resource Providers must be registered in your Azure Subscription. If you have the required permissions, run:

```bash
az provider register --namespace Microsoft.ApiManagement
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.OperationalInsights
```

Check registration status:

```bash
az provider show -n Microsoft.ApiManagement --query registrationState -o tsv
```

> **Note:** Resource Provider registration can take 15–30 minutes. Wait until all Providers show `Registered` status before running `terraform apply`.

> **Note:** In enterprise subscriptions, permissions to register Resource Providers may be restricted. In that case, ask your subscription administrator to register them in advance.

## 1. Clone the Repository

```bash
git clone https://github.com/jihys/apim-foundry-cost-governance.git
cd apim-foundry-cost-governance
```

## 2. Configure the Deployment Config

Copy `terraform.tfvars.example` and fill in your values:

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with values appropriate for your environment:

```hcl
subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
resource_group_name = "rg-apim-foundry"
location            = "koreacentral"

apim_name            = "apim-foundry-gw-mycompany"
apim_sku             = "Developer_1"
apim_publisher_name  = "AI Platform Team"
apim_publisher_email = "admin@example.com"

foundry_resource_name = "aoai-foundry-mycompany"
foundry_projects      = ["team-a-project", "team-b-project"]

model_deployments = [
  {
    name          = "gpt-4o"
    model_name    = "gpt-4o"
    model_version = "2024-11-20"
  }
]
```

> ⚠️ `apim_name` must be globally unique across Azure. A naming convention like `apim-{company}-{env}` is recommended.

> **Note:** Use the `Developer_1` SKU during initial development, and switch to `StandardV2_1` for production deployments. The Developer SKU does not include an SLA.

## 3. Terraform Deployment

### Initialize

```bash
terraform init
```

<!-- screenshot: terraform init success output -->

### Review the Deployment Plan

```bash
terraform plan
```

> **Troubleshooting:** If you encounter a 409 error related to `Resource Provider registration`, verify the Resource Provider registration steps in the Prerequisites section above.

Review the list of resources to be created:

- `azurerm_resource_group` — Resource group
- `azapi_resource.foundry_account` — Foundry Resource (AIServices)
- `azapi_resource.project` — Per-team Foundry Project
- `azapi_resource.model_deployment` — Shared model deployment

<!-- screenshot: terraform plan output (resource list) -->

### Apply the Deployment

> **Tip:** Before deploying, verify model availability in your target region:
> ```bash
> # Check available model versions in the region
> az cognitiveservices model list --location koreacentral \
>   --query "[?model.name=='gpt-4o'].{name:model.name, version:model.version, status:model.lifecycleStatus}" \
>   -o table
> ```

```bash
terraform apply
```

Type `yes` to proceed with the deployment.

<!-- screenshot: terraform apply completion screen -->

### Initialize and Publish Developer Portal (One-Time, Required)

> ⚠️ **Skipping this step makes user Sign up on the Developer Portal impossible.**

Terraform automatically creates the APIM instance and CORS policy, but the Developer Portal's internal identity system requires an administrator to open the Portal admin UI once to initialize.

1. Azure Portal → API Management (`<your-apim-name>`) → left menu **Developer portal**
2. Click the **"Developer portal"** link in the top toolbar → the admin interface opens in a new tab
3. Wait for the admin interface to fully load (this initializes the internal identity system)
4. Switch back to the Azure Portal tab and click the **"Publish"** button

You can also verify publish status via Azure CLI:

```bash
az rest --method GET \
  --uri "https://management.azure.com/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ApiManagement/service/<your-apim-name>/portalRevisions/initial-publish?api-version=2022-08-01" \
  --query properties.status -o tsv
```

The output should be `completed`.

> CORS is automatically configured by Terraform — no separate setup is needed.

> This step is required only once after the initial deployment. Subsequent API/Product changes are automatically reflected by Terraform.

5. (Optional) Welcome message and portal configuration:
   ```bash
   ./scripts/setup-portal.sh <apim-name> <resource-group> <subscription-id>
   ```
   This script sets up a guide message for new users and re-publishes the portal.

## Troubleshooting: Known Errors on First Deploy

The first `terraform apply` may encounter the following errors. These are transient and resolve with a re-run.

### APIM 401 Unauthorized

After APIM resource creation completes (~33 minutes), the azurerm provider may receive a 401 error when listing APIM APIs. This is a transient error caused by APIM internal initialization not being fully complete.

**Solution:** Wait 2–3 minutes, then re-run `terraform apply`.

### Model Deployment 409 Conflict

Multiple model deployments run in parallel, but Azure ARM serializes write operations to the same Cognitive Services account. This can cause 409 Conflict errors during concurrent deployments.

**Solution:** Re-run `terraform apply`. Already-created models are skipped, so the second run succeeds.

**Alternative:** Run `terraform apply -parallelism=1` to avoid parallel conflicts (slower but avoids the error).

### Combined Error Recovery

If both errors occur simultaneously, you may need up to 2 retries:

```bash
terraform apply    # may fail with 401 + 409
# wait 2-3 minutes
terraform apply    # creates remaining resources
```

### Re-deployment Notes (Soft-Delete)

After `terraform destroy`, re-deploying with the same resource names may fail with a conflict. This happens because Azure keeps deleted resources in a soft-delete state for a retention period.

**Foundry (Cognitive Services) account:**
Retained in soft-delete state for 48 hours after deletion. You must purge before re-creating with the same name:

```bash
az cognitiveservices account purge \
  --name <foundry-resource-name> \
  --resource-group <resource-group> \
  --location <location>
```

**APIM:**
APIM instances may also be retained in soft-delete state. Check and purge deleted instances:

```bash
az apim deletedservice list -o table
az apim deletedservice purge \
  --service-name <apim-name> \
  --location <location>
```

## 4. Verify the Deployment

### Check Terraform Outputs

```bash
terraform output foundry_project_endpoints
```

The Foundry Endpoint URL for each Foundry Project will be displayed:

```
{
  "team-a-project" = "https://{foundry-resource-name}.cognitiveservices.azure.com/"
  "team-b-project" = "https://{foundry-resource-name}.cognitiveservices.azure.com/"
}
```

> **Note:** All Foundry Projects share the same parent Foundry resource endpoint. `{foundry-resource-name}` corresponds to the `foundry_resource_name` value in your `terraform.tfvars`.

### Verify in the Azure Portal

1. Go to the [Azure Portal](https://portal.azure.com)
2. Navigate to the resource group `rg-apim-foundry`
3. Confirm the list of created resources

<!-- screenshot: Azure Portal resource group resource list -->

## 5. Check the Service Key (for CI/CD)

Terraform automatically creates a **Service Key** for each Foundry Project. Service Keys are intended for system use only — CI/CD pipelines, automation scripts, etc. — and should not be used by individuals directly.

### Service Key vs Personal Key

| Aspect | Service Key | Personal Key |
|--------|-------------|-------------|
| Issuance | Auto-generated by Terraform | Self-service on Developer Portal |
| Purpose | CI/CD, automation scripts | Individual user API calls |
| Sharing | Shared across systems | Personal only (do not share) |
| Usage tracking | Per-project | Per-user |

```bash
terraform output -json apim_subscription_keys
```

> **Note:** Individual developers obtain their own **Personal Key** via self-service on the Developer Portal. See the [Add User Guide](03-add-user.md) for details.

## Next Steps

- [Add Project Guide](02-add-project.md) — How to add a new Foundry Project
- [Add User Guide](03-add-user.md) — User registration, User Group assignment, and Personal Key issuance
- [User Quickstart](04-user-quickstart.md) — Start making API calls with your Personal Key
