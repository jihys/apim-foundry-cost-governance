variable "resource_group_name" {
  description = "Name of the resource group for APIM resources"
  type        = string
}

variable "location" {
  description = "Azure region for the APIM Instance"
  type        = string
}

variable "apim_name" {
  description = "Name of the APIM Instance"
  type        = string
}

variable "sku" {
  description = "APIM SKU in format Name_Capacity (e.g. Developer_1, StandardV2_1)"
  type        = string
  default     = "Developer_1"
}

variable "publisher_name" {
  description = "Publisher name shown on the APIM Developer Portal"
  type        = string
  default     = "AI Platform Team"
}

variable "publisher_email" {
  description = "Publisher email for the APIM Instance"
  type        = string
  default     = "apim@example.com"
}

variable "project_endpoints" {
  description = "Map of Foundry Project name to Foundry Endpoint URL"
  type        = map(string)
}

variable "project_api_keys" {
  description = "Map of Foundry Project name to Project API Key (stored as APIM Named Values)"
  type        = map(string)
  sensitive   = true
}

variable "app_insights_instrumentation_key" {
  description = "App Insights instrumentation key for the APIM logger"
  type        = string
  sensitive   = true
}

variable "app_insights_id" {
  description = "App Insights resource ID for the APIM logger"
  type        = string
}
