resource "azurerm_resource_group" "doc_intel" {
  name     = "${local.name_prefix}-rg-doc-intel"
  location = var.location
  tags     = local.common_tags
}

# ── Azure AI Document Intelligence (formerly Form Recognizer) ─────────────────
# Capabilities: prebuilt models (invoice, receipt, ID, W-2, tax forms),
#               layout analysis, general document model, custom document models.

resource "azurerm_cognitive_account" "doc_intel" {
  name                  = "${local.name_prefix}-cog-docintel"
  location              = azurerm_resource_group.doc_intel.location
  resource_group_name   = azurerm_resource_group.doc_intel.name
  kind                  = "FormRecognizer"
  sku_name              = var.doc_intel_sku
  custom_subdomain_name = "${local.name_prefix}-cog-docintel"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Storage — source documents for batch analysis and custom model training ───

resource "azurerm_storage_account" "docs" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.doc_intel.name
  location                        = azurerm_resource_group.doc_intel.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "source_docs" {
  name                  = "source-docs"
  storage_account_name  = azurerm_storage_account.docs.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "training_data" {
  name                  = "training-data"
  storage_account_name  = azurerm_storage_account.docs.name
  container_access_type = "private"
}

# ── Diagnostics ───────────────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "doc_intel_diag" {
  name                       = "${local.name_prefix}-diag-docintel"
  target_resource_id         = azurerm_cognitive_account.doc_intel.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
