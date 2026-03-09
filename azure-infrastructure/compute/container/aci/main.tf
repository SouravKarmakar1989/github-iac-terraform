# compute/container/aci — Azure Container Instances
# Cost: ~$0.0000149/vCPU-s + $0.0000015/GiB-s while running.
# 1 vCPU + 1.5 GB for 1 hour ≈ $0.065. Delete when done to stop charges.
# Use restart_policy = "Never" for batch/job workloads.

resource "azurerm_resource_group" "aci" {
  name     = "${local.name_prefix}-rg-aci"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_container_group" "aci" {
  name                = "${local.name_prefix}-aci"
  resource_group_name = azurerm_resource_group.aci.name
  location            = azurerm_resource_group.aci.location
  os_type             = var.os_type
  restart_policy      = var.restart_policy

  container {
    name   = "app"
    image  = var.container_image
    cpu    = var.container_cpu
    memory = var.container_memory

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = "${local.name_prefix}-aci"

  tags = local.common_tags
}
