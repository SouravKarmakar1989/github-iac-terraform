resource "azurerm_resource_group" "ai_search" {
  name     = "${local.name_prefix}-rg-ai-search"
  location = var.location
  tags     = local.common_tags
}

# ── Azure AI Search ────────────────────────────────────────────────────────────
# Full-text + vector + semantic search engine.
# Primary use-cases: RAG (retrieval-augmented generation), knowledge mining,
# semantic ranking, and hybrid search across unstructured content.

resource "azurerm_search_service" "search" {
  name                = "${local.name_prefix}-srch"
  location            = azurerm_resource_group.ai_search.location
  resource_group_name = azurerm_resource_group.ai_search.name
  sku                 = var.search_sku

  local_authentication_enabled   = false
  authentication_failure_mode    = "http403"
  semantic_search_sku            = var.semantic_search_sku

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Diagnostics ───────────────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "search_diag" {
  name                       = "${local.name_prefix}-diag-srch"
  target_resource_id         = azurerm_search_service.search.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
