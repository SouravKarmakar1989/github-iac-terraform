data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "security" {
  name     = "${local.name_prefix}-rg-security"
  location = var.location
  tags     = local.common_tags
}

# ── Azure Key Vault (RBAC mode) ────────────────────────────────────────────────
# Stores secrets, keys, and certificates for all modules in this landing zone.
# RBAC mode is used — use azurerm_role_assignment to grant access to managed
# identities. No legacy access policies.

resource "azurerm_key_vault" "kv" {
  name                       = local.kv_name
  location                   = azurerm_resource_group.security.location
  resource_group_name        = azurerm_resource_group.security.name
  tenant_id                  = var.tenant_id
  sku_name                   = var.kv_sku
  enable_rbac_authorization  = true
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  tags                       = local.common_tags
}

# ── Diagnostics ───────────────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "${local.name_prefix}-diag-kv"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
