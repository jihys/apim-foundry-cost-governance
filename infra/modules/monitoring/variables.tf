variable "resource_group_name" {
  description = "Name of the resource group for monitoring resources"
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources"
  type        = string
}

variable "app_insights_name" {
  description = "Name of the Application Insights resource for App Insights Telemetry"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace backing App Insights"
  type        = string
}

variable "cost_dashboard_display_name" {
  description = "Display name for the Cost Dashboard workbook"
  type        = string
  default     = "Cost Dashboard"
}
