resource "azurerm_resource_group" "apim" {
  name     = "${local.name_prefix}-rg-apim"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_api_management" "apim" {
  name                = "${local.name_prefix}-apim"
  location            = azurerm_resource_group.apim.location
  resource_group_name = azurerm_resource_group.apim.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name
  tags                = local.common_tags

  identity {
    type = "SystemAssigned"
  }
}
