# compute/iaas/vm — Linux Virtual Machine (Ubuntu 22.04 LTS)
# Cost: B1s ~$7/mo running | OS disk ~$1.5/mo even when deallocated.
# Deallocate (not delete) the VM to pause compute charges while keeping the disk.

data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.network_state_resource_group_name
    storage_account_name = var.network_state_storage_account_name
    container_name       = var.network_state_container_name
    key                  = var.network_state_key
  }
}

resource "azurerm_resource_group" "vm" {
  name     = "${local.name_prefix}-rg-vm"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_public_ip" "pip" {
  name                = "${local.name_prefix}-pip-vm"
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name
  allocation_method   = "Dynamic"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.name_prefix}-nic-vm"
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.network.outputs.subnet_ids[var.subnet_name]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${local.name_prefix}-vm"
  resource_group_name             = azurerm_resource_group.vm.name
  location                        = azurerm_resource_group.vm.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = var.ssh_public_key != ""
  admin_password                  = var.ssh_public_key == "" ? var.admin_password : null
  network_interface_ids           = [azurerm_network_interface.nic.id]

  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key != "" ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}
