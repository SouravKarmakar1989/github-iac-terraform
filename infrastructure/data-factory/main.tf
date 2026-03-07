resource "azurerm_resource_group" "adf" {
  name     = "${local.name_prefix}-rg-adf"
  location = var.location
  tags     = local.common_tags
}

# ── Azure Data Factory ────────────────────────────────────────────────────────
# Cost model: workspace creation is $0.
# Free tier: 50 pipeline activity runs/month, 1 TB data movement/month free.
# Charges begin only when pipelines execute beyond the free tier.
# No self-hosted IR or shared IR defined here — add when needed.

resource "azurerm_data_factory" "adf" {
  name                = "${local.name_prefix}-adf"
  location            = azurerm_resource_group.adf.location
  resource_group_name = azurerm_resource_group.adf.name

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}
