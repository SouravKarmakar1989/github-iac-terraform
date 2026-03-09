# compute/serverless/durable-func — Durable Functions (Consumption Y1, Linux, Node.js)
# Two storage accounts: one for the function host, one for Durable task-hub state.
# Cost: First 400K GB-s + 1M executions free/month. Storage ~$1-5/mo each.
# The task-hub storage account connection string is wired in via app settings.

resource "azurerm_resource_group" "df" {
  name     = "${local.name_prefix}-rg-durable"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "host" {
  name                     = local.storage_host_name
  resource_group_name      = azurerm_resource_group.df.name
  location                 = azurerm_resource_group.df.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags
}

resource "azurerm_storage_account" "durable" {
  name                     = local.storage_dur_name
  resource_group_name      = azurerm_resource_group.df.name
  location                 = azurerm_resource_group.df.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags
}

resource "azurerm_service_plan" "df" {
  name                = "${local.name_prefix}-asp-durable"
  resource_group_name = azurerm_resource_group.df.name
  location            = azurerm_resource_group.df.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.common_tags
}

resource "azurerm_linux_function_app" "df" {
  name                       = "${local.name_prefix}-durable"
  resource_group_name        = azurerm_resource_group.df.name
  location                   = azurerm_resource_group.df.location
  storage_account_name       = azurerm_storage_account.host.name
  storage_account_access_key = azurerm_storage_account.host.primary_access_key
  service_plan_id            = azurerm_service_plan.df.id

  app_settings = {
    DURABLE_STORAGE_CONNECTION = azurerm_storage_account.durable.primary_connection_string
  }

  site_config {
    application_stack {
      node_version = var.runtime_version
    }
  }

  tags = local.common_tags
}
