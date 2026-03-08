resource "azurerm_resource_group" "integration" {
  name     = "${local.name_prefix}-rg-integration"
  location = var.location
  tags     = local.common_tags
}

# ── Service Bus Namespace ─────────────────────────────────────────────────────
# Basic SKU: queues only (no topics/subscriptions), $0.013/million operations.
# Upgrade to Standard ($10/mo base) to add topics/subscriptions.
# Standard is required for Event-Driven integration patterns with pub/sub.

resource "azurerm_servicebus_namespace" "sb" {
  name                = "${local.name_prefix}-sb"
  location            = azurerm_resource_group.integration.location
  resource_group_name = azurerm_resource_group.integration.name
  sku                 = var.servicebus_sku

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_servicebus_queue" "default" {
  name         = "default-queue"
  namespace_id = azurerm_servicebus_namespace.sb.id
}

# ── Event Grid Custom Topic ───────────────────────────────────────────────────
# Cost: first 100K operations/month free, then $0.60/million.
# For Azure-native sources (Storage, IoT Hub, etc.) use azurerm_eventgrid_system_topic.

resource "azurerm_eventgrid_topic" "egt" {
  name                = "${local.name_prefix}-egt"
  location            = azurerm_resource_group.integration.location
  resource_group_name = azurerm_resource_group.integration.name
  tags                = local.common_tags
}

# ── Logic App Workflow (Consumption) ─────────────────────────────────────────
# Cost: $0 per run/action when not triggered. First 4K actions/month free.
# Consumption = serverless, pay-per-action. Standard = fixed App Service plan fee.
# Workflow definition (triggers/actions) is configured via the Azure portal or
# azurerm_logic_app_trigger_* / azurerm_logic_app_action_* resources.

resource "azurerm_logic_app_workflow" "la" {
  name                = "${local.name_prefix}-la"
  location            = azurerm_resource_group.integration.location
  resource_group_name = azurerm_resource_group.integration.name

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}
