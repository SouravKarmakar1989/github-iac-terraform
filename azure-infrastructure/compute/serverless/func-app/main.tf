# compute/serverless/func-app — Azure Function App (Consumption Y1)
# Cost: First 400K GB-s + 1M executions free per month (always, not just free tier).
# Storage account ~$1-5/mo depending on usage. No idle compute charge.

resource "azurerm_resource_group" "func" {
  name     = "${local.name_prefix}-rg-func"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "func" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.func.name
  location                 = azurerm_resource_group.func.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags
}

resource "azurerm_service_plan" "func" {
  name                = "${local.name_prefix}-asp-func"
  resource_group_name = azurerm_resource_group.func.name
  location            = azurerm_resource_group.func.location
  os_type             = var.os_type == "linux" ? "Linux" : "Windows"
  sku_name            = "Y1"
  tags                = local.common_tags
}

resource "azurerm_linux_function_app" "func" {
  count = var.os_type == "linux" ? 1 : 0

  name                       = "${local.name_prefix}-func"
  resource_group_name        = azurerm_resource_group.func.name
  location                   = azurerm_resource_group.func.location
  storage_account_name       = azurerm_storage_account.func.name
  storage_account_access_key = azurerm_storage_account.func.primary_access_key
  service_plan_id            = azurerm_service_plan.func.id

  site_config {
    application_stack {
      node_version            = var.runtime == "node" ? var.runtime_version : null
      python_version          = var.runtime == "python" ? var.runtime_version : null
      dotnet_version          = var.runtime == "dotnet" ? var.runtime_version : null
      java_version            = var.runtime == "java" ? var.runtime_version : null
      use_dotnet_isolated_runtime = var.runtime == "dotnet-isolated" ? true : null
    }
  }

  tags = local.common_tags
}

resource "azurerm_windows_function_app" "func" {
  count = var.os_type == "windows" ? 1 : 0

  name                       = "${local.name_prefix}-func"
  resource_group_name        = azurerm_resource_group.func.name
  location                   = azurerm_resource_group.func.location
  storage_account_name       = azurerm_storage_account.func.name
  storage_account_access_key = azurerm_storage_account.func.primary_access_key
  service_plan_id            = azurerm_service_plan.func.id

  site_config {
    application_stack {
      node_version   = var.runtime == "node" ? "~${var.runtime_version}" : null
      dotnet_version = var.runtime == "dotnet" ? "v${var.runtime_version}.0" : null
    }
  }

  tags = local.common_tags
}
