resource "azurerm_resource_group" "content_und" {
  name     = "${local.name_prefix}-rg-content-und"
  location = var.location
  tags     = local.common_tags
}

# ── Azure AI Content Understanding ────────────────────────────────────────────
# Next-generation multimodal document analysis service.
# Capabilities: audio, video, image, and text extraction via a unified API.
# Successor capability to Document Intelligence for complex multi-modal content.

resource "azurerm_cognitive_account" "content_und" {
  name                  = "${local.name_prefix}-cog-contund"
  location              = azurerm_resource_group.content_und.location
  resource_group_name   = azurerm_resource_group.content_und.name
  kind                  = "ContentUnderstanding"
  sku_name              = var.content_sku
  custom_subdomain_name = "${local.name_prefix}-cog-contund"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Diagnostics ───────────────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "content_und_diag" {
  name                       = "${local.name_prefix}-diag-contund"
  target_resource_id         = azurerm_cognitive_account.content_und.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
