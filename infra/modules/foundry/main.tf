# ---------------------------------------------------------------------------
# Shared Foundry Resource (one per environment)
# kind=AIServices enables AI Foundry project hierarchy.
# ---------------------------------------------------------------------------
resource "azapi_resource" "foundry_account" {
  type      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name      = var.foundry_resource_name
  location  = var.location
  parent_id = var.resource_group_id

  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    properties = {
      customSubDomainName    = var.foundry_resource_name
      publicNetworkAccess    = "Enabled"
      allowProjectManagement = true
    }
  }

  response_export_values = ["properties.endpoint"]
}

# ---------------------------------------------------------------------------
# Child projects (one per team) under the shared Foundry resource
# ---------------------------------------------------------------------------
resource "azapi_resource" "project" {
  for_each = toset(var.projects)

  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = each.key
  location  = var.location
  parent_id = azapi_resource.foundry_account.id

  body = {
    properties = {}
  }

  response_export_values = ["properties.endpoint"]
}

# ---------------------------------------------------------------------------
# List keys for the shared Foundry resource (same key for all projects)
# ---------------------------------------------------------------------------
data "azapi_resource_action" "foundry_keys" {
  type        = "Microsoft.CognitiveServices/accounts@2025-06-01"
  resource_id = azapi_resource.foundry_account.id
  action      = "listKeys"

  response_export_values = ["key1"]
}

# ---------------------------------------------------------------------------
# Model deployments (shared at the Foundry resource level)
#
# NOTE: ARM serialises writes to the parent resource, so parallel deployments
# may fail with HTTP 409 Conflict.  If this happens, re-run with:
#   terraform apply -parallelism=1
# ---------------------------------------------------------------------------
resource "azapi_resource" "model_deployment" {
  for_each = { for d in var.model_deployments : d.name => d }

  type      = "Microsoft.CognitiveServices/accounts/deployments@2025-06-01"
  name      = each.value.name
  parent_id = azapi_resource.foundry_account.id

  body = {
    sku = {
      name     = each.value.sku_name
      capacity = coalesce(each.value.rate_limit_tpm, var.default_rate_limit_tpm) / 1000
    }
    properties = {
      model = {
        format  = "OpenAI"
        name    = each.value.model_name
        version = each.value.model_version
      }
    }
  }
}
