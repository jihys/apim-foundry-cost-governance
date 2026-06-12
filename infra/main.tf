resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# ---------------------------------------------------------------------------
# Foundry Projects — provisions Azure AI Services accounts + model deployments
# ---------------------------------------------------------------------------
module "foundry" {
  source = "./modules/foundry"

  resource_group_id      = azurerm_resource_group.main.id
  location               = var.location
  foundry_resource_name  = var.foundry_resource_name
  projects               = var.foundry_projects
  model_deployments      = var.model_deployments
  default_rate_limit_tpm = var.default_rate_limit_tpm
}

# ---------------------------------------------------------------------------
# Monitoring — App Insights + Log Analytics for telemetry pipeline
# ---------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name          = azurerm_resource_group.main.name
  location                     = var.location
  app_insights_name            = var.app_insights_name
  log_analytics_workspace_name = var.log_analytics_workspace_name
}

# ---------------------------------------------------------------------------
# APIM Instance — gateway for Foundry Endpoints with per-project routing
# ---------------------------------------------------------------------------
module "apim" {
  source = "./modules/apim"

  resource_group_name              = azurerm_resource_group.main.name
  location                         = var.location
  apim_name                        = var.apim_name
  sku                              = var.apim_sku
  publisher_name                   = var.apim_publisher_name
  publisher_email                  = var.apim_publisher_email
  project_endpoints                = module.foundry.project_endpoints
  project_api_keys                 = module.foundry.project_api_keys
  app_insights_instrumentation_key = module.monitoring.app_insights_instrumentation_key
  app_insights_id                  = module.monitoring.app_insights_id
}
