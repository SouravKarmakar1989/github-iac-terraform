resource "azurerm_resource_group" "func" {
  name     = "${local.name_prefix}-rg-func"
  location = var.location
  tags     = local.common_tags
}

# Storage account required by the Function App runtime
resource "azurerm_storage_account" "func" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.func.name
  location                        = azurerm_resource_group.func.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_service_plan" "plan" {
  name                = "${local.name_prefix}-asp-func"
  location            = azurerm_resource_group.func.location
  resource_group_name = azurerm_resource_group.func.name
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags                = local.common_tags
}

resource "azurerm_linux_function_app" "func" {
  name                       = "${local.name_prefix}-func"
  location                   = azurerm_resource_group.func.location
  resource_group_name        = azurerm_resource_group.func.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.func.name
  storage_account_access_key = azurerm_storage_account.func.primary_access_key
  https_only                 = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = var.runtime_version
    }
  }

  tags = local.common_tags
}
