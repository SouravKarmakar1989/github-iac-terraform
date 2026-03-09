# compute/container/acr — Azure Container Registry
# Cost: Basic ~$5/mo | Standard ~$20/mo | Premium ~$50/mo (+ per-GB storage after 10 GB).
# Admin access disabled by default — use RBAC (AcrPull / AcrPush) instead.

resource "azurerm_resource_group" "acr" {
  name     = "${local.name_prefix}-rg-acr"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  tags                = local.common_tags
}
