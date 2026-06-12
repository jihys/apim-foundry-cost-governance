output "project_endpoints" {
  description = "Map of Foundry Project name to project endpoint URL"
  value = {
    for name, project in azapi_resource.project :
    name => project.output.properties.endpoint
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
