# compute/iaas/vmss — Linux VM Scale Set (Ubuntu 22.04 LTS)
# Cost: B1s ~$7/mo per instance running. Scale in to 0 instances to pause charges.
# Add azurerm_monitor_autoscale_setting to this module for auto-scaling rules.

data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.network_state_resource_group_name
    storage_account_name = var.network_state_storage_account_name
    container_name       = var.network_state_container_name
    key                  = var.network_state_key
  }
}

resource "azurerm_resource_group" "vmss" {
  name     = "${local.name_prefix}-rg-vmss"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "${local.name_prefix}-vmss"
  resource_group_name             = azurerm_resource_group.vmss.name
  location                        = azurerm_resource_group.vmss.location
  sku                             = var.sku
  instances                       = var.instances
  admin_username                  = var.admin_username
  disable_password_authentication = var.ssh_public_key != ""
  admin_password                  = var.ssh_public_key == "" ? var.admin_password : null
  upgrade_mode                    = var.upgrade_mode

  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key != "" ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.terraform_remote_state.network.outputs.subnet_ids[var.subnet_name]
    }
  }

  tags = local.common_tags
}
