resource "azurerm_resource_group" "observability" {
  name     = "${local.name_prefix}-rg-observability"
  location = var.location
  tags     = local.common_tags
}

# ── Azure Log Analytics Workspace ─────────────────────────────────────────────
# Central log sink for the entire landing zone.
# All modules reference this workspace ID for diagnostic settings,
# Container Apps environments, AKS clusters, and Application Insights.

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name_prefix}-law"
  location            = azurerm_resource_group.observability.location
  resource_group_name = azurerm_resource_group.observability.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}
