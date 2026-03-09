# compute/container/aca — Azure Container Apps
# Cost: Consumption plan — pay per vCPU-second and GiB-second while running.
# Free grant: 180,000 vCPU-s + 360,000 GiB-s per month per subscription.
# Set min_replicas = 0 for scale-to-zero; idle cost is $0.

resource "azurerm_resource_group" "aca" {
  name     = "${local.name_prefix}-rg-aca"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_log_analytics_workspace" "aca" {
  name                = "${local.name_prefix}-law-aca"
  resource_group_name = azurerm_resource_group.aca.name
  location            = azurerm_resource_group.aca.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_container_app_environment" "env" {
  name                       = "${local.name_prefix}-cae"
  resource_group_name        = azurerm_resource_group.aca.name
  location                   = azurerm_resource_group.aca.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca.id
  tags                       = local.common_tags
}

resource "azurerm_container_app" "app" {
  name                         = "${local.name_prefix}-ca"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.aca.name
  revision_mode                = "Single"

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "app"
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory
    }
  }

  ingress {
    external_enabled = var.ingress_external
    target_port      = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = local.common_tags
}
