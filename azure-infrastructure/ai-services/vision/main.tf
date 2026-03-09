resource "azurerm_resource_group" "vision" {
  name     = "${local.name_prefix}-rg-vision"
  location = var.location
  tags     = local.common_tags
}

# ── Azure AI Vision (Computer Vision) ────────────────────────────────────────
# Capabilities: image analysis, dense captions, OCR (Read API),
#               background removal, smart crop, spatial analysis.

resource "azurerm_cognitive_account" "vision" {
  name                  = "${local.name_prefix}-cog-vision"
  location              = azurerm_resource_group.vision.location
  resource_group_name   = azurerm_resource_group.vision.name
  kind                  = "ComputerVision"
  sku_name              = var.vision_sku
  custom_subdomain_name = "${local.name_prefix}-cog-vision"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Diagnostics ───────────────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "vision_diag" {
  name                       = "${local.name_prefix}-diag-vision"
  target_resource_id         = azurerm_cognitive_account.vision.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
