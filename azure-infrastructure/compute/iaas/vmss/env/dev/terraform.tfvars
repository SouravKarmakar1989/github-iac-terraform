prefix   = "sk"
location = "eastus"
env      = "dev"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/dev.tfstate"

sku           = "Standard_B1s"
instances     = 1
admin_username = "azureuser"
subnet_name   = "snet-vm"
upgrade_mode  = "Manual"
