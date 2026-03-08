resource "azurerm_resource_group" "sql" {
  name     = "${local.name_prefix}-rg-sql"
  location = var.location
  tags     = local.common_tags
}

# ── Azure SQL Server ──────────────────────────────────────────────────────────
resource "azurerm_mssql_server" "sql" {
  name                         = "${local.name_prefix}-sqlsrv"
  resource_group_name          = azurerm_resource_group.sql.name
  location                     = azurerm_resource_group.sql.location
  version                      = "12.0"
  administrator_login          = var.sql_admin
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Allow Azure services (e.g. GitHub Actions, ADF) to connect
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ── Serverless Database — pay-per-use, auto-pauses when idle ─────────────────
# GP_S_Gen5_1 = General Purpose Serverless, max 1 vCore
# Cost: ~$0.000145/vCore-second when active. $0 when auto-paused.
# Azure SQL free offer: 100K vCore-seconds + 32 GB/month (1 per subscription).
# free_limit_exhaustion_behavior = "AutoPause" → auto-pause when free quota exhausted.

resource "azurerm_mssql_database" "db" {
  name      = "${local.name_prefix}-sqldb"
  server_id = azurerm_mssql_server.sql.id

  sku_name                       = "GP_S_Gen5_1"
  min_capacity                   = 0.5
  auto_pause_delay_in_minutes    = 60
  max_size_gb                    = 32

  free_limit_exhaustion_behavior = var.use_free_tier ? "AutoPause" : null

  tags = local.common_tags
}
