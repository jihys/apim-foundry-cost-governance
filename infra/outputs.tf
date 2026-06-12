output "foundry_project_endpoints" {
  description = "Map of Foundry Project name to Foundry Endpoint URL"
  value       = module.foundry.project_endpoints
}

output "apim_endpoint" {
  description = "APIM Instance gateway URL"
  value       = module.apim.gateway_url
}

output "apim_subscription_keys" {
  description = "APIM Subscription keys per Foundry Project (sensitive)"
  value       = module.apim.subscription_keys
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "App Insights connection string for App Insights Telemetry"
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}

output "apim_developer_portal_url" {
  description = "APIM Developer Portal URL for user self-service"
  value       = module.apim.developer_portal_url
}
