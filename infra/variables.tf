variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for all resources"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "koreacentral"
}

variable "apim_name" {
  description = "Name of the APIM Instance"
  type        = string
}

variable "apim_sku" {
  description = "APIM SKU in format Name_Capacity (e.g. Developer_1, StandardV2_1)"
  type        = string
  default     = "Developer_1"
}

variable "apim_publisher_name" {
  description = "Publisher name shown on the APIM Developer Portal"
  type        = string
  default     = "AI Platform Team"
}

variable "apim_publisher_email" {
  description = "Publisher email for the APIM Instance"
  type        = string
  default     = "apim@example.com"
}

variable "foundry_hub_name" {
  description = "Name of the shared Azure AI Services (Foundry) resource"
  type        = string
  default     = "aoai-foundry"
}

variable "foundry_projects" {
  description = "List of Foundry Project names (one per team). Each becomes a child resource under the shared Foundry account."
  type        = list(string)
}

variable "model_deployments" {
  description = "Shared model deployments at the Foundry resource level"
  type = list(object({
    name           = string
    model_name     = string
    model_version  = string
    sku_name       = optional(string, "GlobalStandard")
    rate_limit_tpm = optional(number)
  }))
}

variable "default_rate_limit_tpm" {
  description = "Default rate limit in tokens per minute for model deployments"
  type        = number
  default     = 10000
}

variable "app_insights_name" {
  description = "Name of the Application Insights resource for App Insights Telemetry"
  type        = string
  default     = "appi-foundry"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace backing App Insights"
  type        = string
  default     = "law-foundry"
}
