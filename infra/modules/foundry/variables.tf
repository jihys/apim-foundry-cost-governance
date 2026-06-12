variable "resource_group_id" {
  description = "ID of the parent resource group"
  type        = string
}

variable "location" {
  description = "Azure region for Foundry resources"
  type        = string
}

variable "foundry_resource_name" {
  description = "Name of the shared Azure AI Services (Foundry) resource"
  type        = string
}

variable "projects" {
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
  description = "Default rate limit in tokens per minute, used when a deployment does not specify rate_limit_tpm"
  type        = number
  default     = 10000
}
