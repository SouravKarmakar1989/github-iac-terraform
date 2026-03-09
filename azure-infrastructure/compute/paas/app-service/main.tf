# compute/paas/app-service — App Service Plan + Web App
# SKU ladder: F1 (free) → B1 (~$13/mo) → S1 (~$73/mo) → P1v3 (~$139/mo) → P0v3 (~$85/mo)
# F1 has no custom domain, no SSL, no always-on, no deployment slots.
# Use os_type = "Windows" + adjust runtime_stack for .NET / classic ASP apps.

resource "azurerm_resource_group" "app" {
  name     = "${local.name_prefix}-rg-app-service"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_service_plan" "plan" {
  name                = "${local.name_prefix}-asp"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags                = local.common_tags
}

resource "azurerm_linux_web_app" "app" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = "${local.name_prefix}-webapp"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = var.always_on

    application_stack {
      # Supports: node_version, python_version, dotnet_version, php_version, ruby_version
      # Set via runtime_stack e.g. "NODE|20-lts" → parsed below
      node_version = startswith(var.runtime_stack, "NODE|") ? trimprefix(var.runtime_stack, "NODE|") : null
    }
  }

  tags = local.common_tags
}

resource "azurerm_windows_web_app" "app" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = "${local.name_prefix}-webapp"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = var.always_on

    application_stack {
      current_stack  = "node"
      node_version   = "~20"
    }
  }

  tags = local.common_tags
}
