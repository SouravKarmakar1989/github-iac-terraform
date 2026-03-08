resource "azurerm_resource_group" "vnet" {
  name     = "${local.name_prefix}-rg-vnet"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  address_space       = var.address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = "${local.name_prefix}-snet-${each.key}"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
}
