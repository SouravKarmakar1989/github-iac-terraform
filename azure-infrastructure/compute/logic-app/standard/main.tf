# compute/logic-app/standard — Logic App Standard
# Cost: WS1 ~$185/mo (always on, unlike Consumption).
# Standard gives VNet integration, stateful/stateless workflows, custom connectors.
# Requires a dedicated App Service Plan (WS1/WS2/WS3) and a Storage Account.

resource "azurerm_resource_group" "las" {
  name     = "${local.name_prefix}-rg-logic-standard"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "las" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.las.name
  location                 = azurerm_resource_group.las.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags
}

resource "azurerm_service_plan" "las" {
  name                = "${local.name_prefix}-asp-logic-std"
  resource_group_name = azurerm_resource_group.las.name
  location            = azurerm_resource_group.las.location
  os_type             = "Windows"
  sku_name            = var.sku_name
  tags                = local.common_tags
}

resource "azurerm_logic_app_standard" "las" {
  name                       = "${local.name_prefix}-logic-std"
  resource_group_name        = azurerm_resource_group.las.name
  location                   = azurerm_resource_group.las.location
  app_service_plan_id        = azurerm_service_plan.las.id
  storage_account_name       = azurerm_storage_account.las.name
  storage_account_access_key = azurerm_storage_account.las.primary_access_key
  tags                       = local.common_tags
}
