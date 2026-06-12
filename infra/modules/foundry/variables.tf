variable "resource_group_id" {
  description = "ID of the parent resource group"
  type        = string
}

variable "location" {
  description = "Azure region for Foundry Project resources"
  type        = string
}

variable "foundry_hub_name" {
  description = "Name prefix for Azure AI Services accounts (each Foundry Project gets {prefix}-{project_name})"
  type        = string
}

variable "projects" {
  description = "List of Foundry Project configurations. Each entry creates an Azure AI Services account and deploys the specified models."
  type = list(object({
    name           = string
    models         = list(string)
    rate_limit_tpm = optional(number)
  }))
}

variable "default_rate_limit_tpm" {
  description = "Default rate limit in tokens per minute, used when a project does not specify rate_limit_tpm"
  type        = number
  default     = 10000
}
