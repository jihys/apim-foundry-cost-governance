# ---------------------------------------------------------------------------
# APIM Instance
# ---------------------------------------------------------------------------
resource "azurerm_api_management" "main" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku

  sign_up {
    enabled = true
    terms_of_service {
      enabled          = false
      consent_required = false
    }
  }

  sign_in {
    enabled = true
  }
}

# ---------------------------------------------------------------------------
# App Insights Logger — connects APIM to App Insights Telemetry
# ---------------------------------------------------------------------------
resource "azurerm_api_management_logger" "app_insights" {
  name                = "${var.apim_name}-logger"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  resource_id         = var.app_insights_id

  application_insights {
    instrumentation_key = var.app_insights_instrumentation_key
  }
}

# ---------------------------------------------------------------------------
# APIM Diagnostic — configures request/response logging to App Insights
# ---------------------------------------------------------------------------
resource "azurerm_api_management_diagnostic" "app_insights" {
  identifier               = "applicationinsights"
  api_management_name      = azurerm_api_management.main.name
  resource_group_name      = var.resource_group_name
  api_management_logger_id = azurerm_api_management_logger.app_insights.id

  sampling_percentage = 100
  always_log_errors   = true
  log_client_ip       = true
  verbosity           = "information"
}

# ---------------------------------------------------------------------------
# Named Values — Project API Keys stored as secrets for policy references
# ---------------------------------------------------------------------------
resource "azurerm_api_management_named_value" "project_api_key" {
  for_each = var.project_endpoints

  name                = "${each.key}-api-key"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.main.name
  display_name        = "${each.key}-api-key"
  value               = var.project_api_keys[each.key]
  secret              = true
}

# ---------------------------------------------------------------------------
# OpenAI-compatible API — single API shared across all Foundry Project products.
# Routing to the correct Foundry Endpoint is handled by per-product policies
# based on the APIM Subscription key.
# ---------------------------------------------------------------------------
resource "azurerm_api_management_api" "openai" {
  name                = "openai-api"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  revision            = "1"
  display_name        = "OpenAI API"
  path                = "openai"
  protocols           = ["https"]

  subscription_key_parameter_names {
    header = "api-key"
    query  = "subscription-key"
  }
}

# ---------------------------------------------------------------------------
# API Operations — OpenAI-compatible endpoints
# ---------------------------------------------------------------------------
resource "azurerm_api_management_api_operation" "chat_completions" {
  operation_id        = "chat-completions"
  api_name            = azurerm_api_management_api.openai.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  display_name        = "Chat Completions"
  method              = "POST"
  url_template        = "/deployments/{deployment-id}/chat/completions"

  template_parameter {
    name     = "deployment-id"
    required = true
    type     = "string"
  }
}

resource "azurerm_api_management_api_operation" "completions" {
  operation_id        = "completions"
  api_name            = azurerm_api_management_api.openai.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  display_name        = "Completions"
  method              = "POST"
  url_template        = "/deployments/{deployment-id}/completions"

  template_parameter {
    name     = "deployment-id"
    required = true
    type     = "string"
  }
}

resource "azurerm_api_management_api_operation" "embeddings" {
  operation_id        = "embeddings"
  api_name            = azurerm_api_management_api.openai.name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  display_name        = "Embeddings"
  method              = "POST"
  url_template        = "/deployments/{deployment-id}/embeddings"

  template_parameter {
    name     = "deployment-id"
    required = true
    type     = "string"
  }
}

# ---------------------------------------------------------------------------
# Per Foundry Project resources — Product, Backend, Subscription, User Group
# ---------------------------------------------------------------------------

# APIM Backend per Foundry Project — points to the project's Foundry Endpoint
resource "azurerm_api_management_backend" "project" {
  for_each = var.project_endpoints

  name                = "${each.key}-backend"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  protocol            = "http"
  url                 = "${trimsuffix(each.value, "/")}/openai"
}

# APIM Product per Foundry Project (1:1 mapping, implementation detail)
resource "azurerm_api_management_product" "project" {
  for_each = var.project_endpoints

  product_id            = each.key
  api_management_name   = azurerm_api_management.main.name
  resource_group_name   = var.resource_group_name
  display_name          = each.key
  description           = "Foundry Model access management for the ${each.key} team. Managed by ${var.publisher_name}."
  subscription_required = true
  subscriptions_limit   = 1
  approval_required     = false
  published             = true
}

# Associate the OpenAI API with each Product
resource "azurerm_api_management_product_api" "project" {
  for_each = var.project_endpoints

  api_name            = azurerm_api_management_api.openai.name
  product_id          = azurerm_api_management_product.project[each.key].product_id
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
}

# APIM Subscription per Foundry Project — shared team key
resource "azurerm_api_management_subscription" "project" {
  for_each = var.project_endpoints

  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  product_id          = azurerm_api_management_product.project[each.key].id
  display_name        = "${each.key}-service-key"
  state               = "active"
}

# User Group per Foundry Project — for Developer Portal self-service
resource "azurerm_api_management_group" "project" {
  for_each = var.project_endpoints

  name                = "${each.key}-users"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
  display_name        = "${each.key} Users"
}

# Product-Group association
resource "azurerm_api_management_product_group" "project" {
  for_each = var.project_endpoints

  product_id          = azurerm_api_management_product.project[each.key].product_id
  group_name          = azurerm_api_management_group.project[each.key].name
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Product Policy per Foundry Project — routes requests to the correct backend
# and swaps the APIM Subscription key for the Project API Key.
# ---------------------------------------------------------------------------
resource "azurerm_api_management_product_policy" "project" {
  for_each = var.project_endpoints

  product_id          = azurerm_api_management_product.project[each.key].product_id
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name

  xml_content = <<-XML
    <policies>
      <inbound>
        <base />
        <set-backend-service backend-id="${azurerm_api_management_backend.project[each.key].name}" />
        <set-header name="api-key" exists-action="override">
          <value>{{${azurerm_api_management_named_value.project_api_key[each.key].display_name}}}</value>
        </set-header>
      </inbound>
      <backend>
        <base />
      </backend>
      <outbound>
        <base />
        <choose>
          <when condition="@(context.Response.StatusCode == 200)">
            <set-variable name="responseBody" value="@(context.Response.Body.As&lt;JObject&gt;(preserveContent: true))" />
            <set-variable name="promptTokens" value="@{var body = (JObject)context.Variables[&quot;responseBody&quot;]; return body[&quot;usage&quot;]?[&quot;prompt_tokens&quot;]?.ToString() ?? &quot;0&quot;;}" />
            <set-variable name="completionTokens" value="@{var body = (JObject)context.Variables[&quot;responseBody&quot;]; return body[&quot;usage&quot;]?[&quot;completion_tokens&quot;]?.ToString() ?? &quot;0&quot;;}" />
            <set-variable name="totalTokens" value="@{var body = (JObject)context.Variables[&quot;responseBody&quot;]; return body[&quot;usage&quot;]?[&quot;total_tokens&quot;]?.ToString() ?? &quot;0&quot;;}" />
            <set-variable name="modelName" value="@{var body = (JObject)context.Variables[&quot;responseBody&quot;]; return body[&quot;model&quot;]?.ToString() ?? &quot;unknown&quot;;}" />
            <emit-metric name="TokenUsage" value="@(Convert.ToDouble((string)context.Variables[&quot;totalTokens&quot;]))" namespace="apim-foundry">
              <dimension name="subscription-id" value="@(context.Subscription.Id)" />
              <dimension name="subscriber" value="@(context.User.Email ?? context.User.Id)" />
              <dimension name="project-name" value="@(context.Product.Name)" />
              <dimension name="model" value="@((string)context.Variables[&quot;modelName&quot;])" />
              <dimension name="prompt-tokens" value="@((string)context.Variables[&quot;promptTokens&quot;])" />
              <dimension name="completion-tokens" value="@((string)context.Variables[&quot;completionTokens&quot;])" />
              <dimension name="total-tokens" value="@((string)context.Variables[&quot;totalTokens&quot;])" />
            </emit-metric>
          </when>
        </choose>
      </outbound>
      <on-error>
        <base />
      </on-error>
    </policies>
  XML

  depends_on = [
    azurerm_api_management_named_value.project_api_key,
    azurerm_api_management_backend.project,
  ]
}
