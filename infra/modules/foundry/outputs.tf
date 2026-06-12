output "project_endpoints" {
  description = "Map of Foundry Project name to endpoint URL (all use parent account endpoint)"
  value = {
    for name in var.projects :
    name => azapi_resource.foundry_account.output.endpoint
  }
}

output "project_api_keys" {
  description = "Map of Foundry Project name to API key (shared across all projects)"
  value = {
    for name in var.projects :
    name => data.azapi_resource_action.foundry_keys.output.key1
  }
  sensitive = true
}
