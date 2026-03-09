# ---------------------------------------------------------------------------
# compute/static-web-app — Azure Static Web Apps
#
# Free tier ($0):
#   - Global CDN, custom domains with free managed SSL
#   - Built-in CI/CD with GitHub Actions or Azure DevOps
#   - 100 GB bandwidth/mo, 2 custom domains, serverless API via Azure Functions
#
# Standard tier ($9/mo):
#   - All Free features + private endpoints, SLA, unlimited bandwidth
#   - Required for enterprise auth providers (AAD, custom OIDC)
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "swa" {
  name     = "${local.name_prefix}-rg-swa"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_static_web_app" "swa" {
  name                = "${local.name_prefix}-swa"
  location            = azurerm_resource_group.swa.location
  resource_group_name = azurerm_resource_group.swa.name
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size
  tags                = local.common_tags
}
