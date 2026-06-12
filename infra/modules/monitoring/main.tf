# ---------------------------------------------------------------------------
# Log Analytics Workspace — backing store for App Insights Telemetry
# ---------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# ---------------------------------------------------------------------------
# Application Insights — collects APIM request telemetry and Token Usage
# ---------------------------------------------------------------------------
resource "azurerm_application_insights" "main" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.main.id
}

# ---------------------------------------------------------------------------
# Cost Dashboard — App Insights Workbook for Token Usage and estimated cost
# ---------------------------------------------------------------------------
resource "azurerm_application_insights_workbook" "cost_dashboard" {
  name                = "a3f0c8e2-7b5d-4921-8f6e-1c3d5a7b9e0f"
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = var.cost_dashboard_display_name
  source_id           = lower(azurerm_application_insights.main.id)
  category            = "workbook"

  data_json = templatefile("${path.module}/workbook-template.json", {
    app_insights_id = azurerm_application_insights.main.id
    location        = var.location
  })
}
