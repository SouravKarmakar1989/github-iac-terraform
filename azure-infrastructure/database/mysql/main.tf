resource "azurerm_resource_group" "mysql" {
  name     = "${local.name_prefix}-rg-mysql"
  location = var.location
  tags     = local.common_tags
}

# ── MySQL Flexible Server ─────────────────────────────────────────────────────
# Cost: B_Standard_B1ms ~$7.40/month (no free tier).
# ⚠️ No auto-pause on MySQL Flexible Server — billed continuously while provisioned.
# To save cost: use rg-destroy workflow to tear down when not in use.

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${local.name_prefix}-mysql"
  resource_group_name    = azurerm_resource_group.mysql.name
  location               = azurerm_resource_group.mysql.location
  administrator_login    = var.mysql_admin
  administrator_password = var.mysql_admin_password
  sku_name               = var.mysql_sku
  version                = var.mysql_version
  backup_retention_days  = 7

  tags = local.common_tags
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.mysql.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
