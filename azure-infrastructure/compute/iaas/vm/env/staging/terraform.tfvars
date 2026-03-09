prefix   = "sk"
location = "eastus"
env      = "staging"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/staging.tfstate"

vm_size        = "Standard_B2s"
admin_username = "azureuser"
subnet_name    = "snet-vm"
os_disk_type   = "StandardSSD_LRS"
