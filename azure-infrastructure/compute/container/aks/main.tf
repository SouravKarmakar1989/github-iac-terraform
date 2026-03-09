# compute/container/aks — Azure Kubernetes Service
# Cost: Free tier cluster management = $0. Pay per node VM (D2s_v3 ~$70/mo).
# sku_tier = "Standard" adds 99.95% SLA at ~$73/mo per cluster.
# Set node_count = 0 (if using a User node pool) to pause node charges while keeping control plane.

data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.network_state_resource_group_name
    storage_account_name = var.network_state_storage_account_name
    container_name       = var.network_state_container_name
    key                  = var.network_state_key
  }
}

resource "azurerm_resource_group" "aks" {
  name     = "${local.name_prefix}-rg-aks"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${local.name_prefix}-law-aks"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.name_prefix}-aks"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  dns_prefix          = "${local.name_prefix}-aks"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  default_node_pool {
    name           = "system"
    vm_size        = var.node_vm_size
    node_count     = var.node_count
    vnet_subnet_id = data.terraform_remote_state.network.outputs.subnet_ids[var.subnet_name]
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  tags = local.common_tags
}
