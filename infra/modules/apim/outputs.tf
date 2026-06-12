output "gateway_url" {
  description = "APIM Instance gateway URL"
  value       = azurerm_api_management.main.gateway_url
}

output "apim_id" {
  description = "APIM Instance resource ID"
  value       = azurerm_api_management.main.id
}

output "subscription_keys" {
  description = "Map of Foundry Project name to APIM Subscription primary key"
  value = {
    for name, sub in azurerm_api_management_subscription.project :
    name => sub.primary_key
  }
  sensitive = true
}
