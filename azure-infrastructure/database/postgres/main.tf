resource "azurerm_resource_group" "postgres" {
  name     = "${local.name_prefix}-rg-postgres"
  location = var.location
  tags     = local.common_tags
}

# ── PostgreSQL Flexible Server ────────────────────────────────────────────────
# Cost: B_Standard_B1ms ~$12.41/month (no free tier — cheapest available SKU).
# ⚠️ Unlike SQL Server/Cosmos, there is NO free tier for PostgreSQL Flexible Server.
# Burstable (B_Standard_*) tier is pay-per-hour regardless of usage.
# To save cost: delete the server when not actively practicing, redeploy when needed.
# Alternatively use Azure SQL serverless (database/sql module) which auto-pauses.

resource "azurerm_postgresql_flexible_server" "pgfs" {
  name                   = "${local.name_prefix}-pgfs"
  resource_group_name    = azurerm_resource_group.postgres.name
  location               = azurerm_resource_group.postgres.location
  version                = var.pg_version
  administrator_login    = var.pg_admin
  administrator_password = var.pg_admin_password
  sku_name               = var.pg_sku
  storage_mb             = var.storage_mb
  backup_retention_days  = 7

  tags = local.common_tags
}

# Allow connections from Azure services (e.g. ADF, App Service)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.pgfs.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
