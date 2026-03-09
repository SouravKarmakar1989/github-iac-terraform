# compute/container/spring-apps — Azure Spring Apps
# Cost: B0 (Basic) ~$25/mo | S0 (Standard) ~$100/mo per service instance.
# Apps deployed to this service are billed additionally per vCPU/memory.

resource "azurerm_resource_group" "spring" {
  name     = "${local.name_prefix}-rg-spring"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_spring_cloud_service" "spring" {
  name                = "${local.name_prefix}-spring"
  resource_group_name = azurerm_resource_group.spring.name
  location            = azurerm_resource_group.spring.location
  sku_name            = var.sku_name
  tags                = local.common_tags
}
