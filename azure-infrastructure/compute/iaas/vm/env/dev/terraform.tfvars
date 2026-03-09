prefix   = "sk"
location = "eastus"
env      = "dev"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/dev.tfstate"

vm_size        = "Standard_B1s"
admin_username = "azureuser"
subnet_name    = "snet-vm"
os_disk_type   = "Standard_LRS"
