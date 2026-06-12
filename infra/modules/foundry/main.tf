locals {
  model_deployments = flatten([
    for project in var.projects : [
      for model in project.models : {
        project_name   = project.name
        model_name     = model
        rate_limit_tpm = coalesce(project.rate_limit_tpm, var.default_rate_limit_tpm)
      }
    ]
  ])
}

# ---------------------------------------------------------------------------
# Azure AI Services account per Foundry Project
# Each project gets its own account with an independent Foundry Endpoint.
# ---------------------------------------------------------------------------
resource "azapi_resource" "foundry_account" {
  for_each = { for p in var.projects : p.name => p }

  type      = "Microsoft.CognitiveServices/accounts@2024-10-01"
  name      = "${var.foundry_hub_name}-${each.key}"
  location  = var.location
  parent_id = var.resource_group_id

  body = {
    kind = "OpenAI"
    sku = {
      name = "S0"
    }
    properties = {
      customSubDomainName = "${var.foundry_hub_name}-${each.key}"
      publicNetworkAccess = "Enabled"
    }
  }

  response_export_values = ["properties.endpoint"]
}

# ---------------------------------------------------------------------------
# List keys for each Foundry Project account (Project API Key)
# ---------------------------------------------------------------------------
data "azapi_resource_action" "foundry_keys" {
  for_each = { for p in var.projects : p.name => p }

  type        = "Microsoft.CognitiveServices/accounts@2024-10-01"
  resource_id = azapi_resource.foundry_account[each.key].id
  action      = "listKeys"

  response_export_values = ["key1"]
}

# ---------------------------------------------------------------------------
# Model deployments per Foundry Project
# ---------------------------------------------------------------------------
resource "azapi_resource" "model_deployment" {
  for_each = {
    for d in local.model_deployments : "${d.project_name}-${d.model_name}" => d
  }

  type      = "Microsoft.CognitiveServices/accounts/deployments@2024-10-01"
  name      = each.value.model_name
  parent_id = azapi_resource.foundry_account[each.value.project_name].id

  body = {
    sku = {
      name     = "Standard"
      capacity = each.value.rate_limit_tpm / 1000
    }
    properties = {
      model = {
        format  = "OpenAI"
        name    = each.value.model_name
        version = "latest"
      }
    }
  }
}
