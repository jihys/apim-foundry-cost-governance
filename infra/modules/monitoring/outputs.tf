output "app_insights_instrumentation_key" {
  description = "App Insights instrumentation key for APIM logger integration"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "app_insights_id" {
  description = "App Insights resource ID"
  value       = azurerm_application_insights.main.id
}

output "app_insights_connection_string" {
  description = "App Insights connection string for App Insights Telemetry"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "cost_dashboard_id" {
  description = "Cost Dashboard workbook resource ID"
  value       = azurerm_application_insights_workbook.cost_dashboard.id
}
