# Initial Setup Guide

> 🇰🇷 [한국어 버전](../01-initial-setup.md)

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

### Developer Portal Initial Setup (One-Time)

To activate the Developer Portal after the Terraform deployment:

1. Azure Portal → API Management (`apim-foundry-gw-jihys`) → left menu **Developer portal**
2. Click the **"Developer portal"** link in the top toolbar → the admin interface opens in a new tab
3. After the admin interface loads, switch back to the Azure Portal tab and refresh the page
4. Click the **"Publish"** button

> This step is required only once after the initial deployment. Subsequent API/Product changes are automatically reflected by Terraform.

5. (Optional) Welcome message and portal configuration:
   ```bash
   ./scripts/setup-portal.sh <apim-name> <resource-group> <subscription-id>
   ```
   This script sets up a guide message for new users and re-publishes the portal.

## 4. Verify the Deployment

### Check Terraform Outputs

```bash
terraform output foundry_project_endpoints
```

The Foundry Endpoint URL for each Foundry Project will be displayed:

```
{
  "catalog" = "https://aoai-foundry-catalog.openai.azure.com/"
  "image"   = "https://aoai-foundry-image.openai.azure.com/"
}
```

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
