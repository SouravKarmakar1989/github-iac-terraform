# compute/logic-app/consumption — Logic App (Consumption)
# Cost: Pay per action execution (~$0.000025/action). $0 idle.
# First 4,000 actions per month free.
# Workflow definition is empty here — add triggers/actions via Azure Portal or ARM.

resource "azurerm_resource_group" "la" {
  name     = "${local.name_prefix}-rg-logic-consumption"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_logic_app_workflow" "la" {
  name                = "${local.name_prefix}-logic"
  resource_group_name = azurerm_resource_group.la.name
  location            = azurerm_resource_group.la.location
  tags                = local.common_tags
}
