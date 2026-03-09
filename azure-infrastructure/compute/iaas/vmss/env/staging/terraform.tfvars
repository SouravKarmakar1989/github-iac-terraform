prefix   = "sk"
location = "eastus"
env      = "staging"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/staging.tfstate"

sku           = "Standard_B2s"
instances     = 2
admin_username = "azureuser"
subnet_name   = "snet-vm"
upgrade_mode  = "Manual"
