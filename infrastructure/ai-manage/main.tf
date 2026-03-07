data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "ai" {
  name     = "${local.name_prefix}-rg-ai-manage"
  location = var.location
  tags     = local.common_tags
}

# ── Observability ───────────────────────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name_prefix}-law-ai"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

resource "azurerm_application_insights" "appi" {
  name                = "${local.name_prefix}-appi-ai"
  location            = azurerm_resource_group.ai.location
  resource_group_name = azurerm_resource_group.ai.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  tags                = local.common_tags
}

# ── Key Vault (RBAC mode — no access policies) ─────────────────────────────────

resource "azurerm_key_vault" "kv" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.ai.location
  resource_group_name         = azurerm_resource_group.ai.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  tags                        = local.common_tags
}

# ── Cognitive Services multi-service account ────────────────────────────────────
# Covers: Vision, Language, Speech, Decision — single endpoint + key
# AI-102: "Plan and manage an Azure AI solution"

resource "azurerm_cognitive_account" "ai" {
  name                  = "${local.name_prefix}-cog-ai"
  location              = azurerm_resource_group.ai.location
  resource_group_name   = azurerm_resource_group.ai.name
  kind                  = "CognitiveServices"  # multi-service
  sku_name              = var.cognitive_sku
  custom_subdomain_name = "${local.name_prefix}-cog-ai"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Diagnostics → Log Analytics ────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "cog_diag" {
  name                       = "${local.name_prefix}-diag-cog"
  target_resource_id         = azurerm_cognitive_account.ai.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# ── Store Cognitive Services key in Key Vault ──────────────────────────────────

resource "azurerm_key_vault_secret" "cog_key" {
  name         = "cognitive-services-key"
  value        = azurerm_cognitive_account.ai.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault.kv]
}
