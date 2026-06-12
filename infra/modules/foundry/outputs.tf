output "project_endpoints" {
  description = "Map of Foundry Project name to Foundry Endpoint URL"
  value = {
    for name, account in azapi_resource.foundry_account :
    name => account.output.properties.endpoint
  }
}

output "project_api_keys" {
  description = "Map of Foundry Project name to Project API Key"
  value = {
    for name, action in data.azapi_resource_action.foundry_keys :
    name => action.output.key1
  }
  sensitive = true
}
