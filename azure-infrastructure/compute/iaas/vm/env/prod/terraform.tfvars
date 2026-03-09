prefix   = "sk"
location = "eastus"
env      = "prod"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/prod.tfstate"

vm_size        = "Standard_D2s_v3"
admin_username = "azureuser"
subnet_name    = "snet-vm"
os_disk_type   = "Premium_LRS"
