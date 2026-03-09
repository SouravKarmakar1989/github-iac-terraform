prefix   = "sk"
location = "eastus"
env      = "prod"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/prod.tfstate"

sku           = "Standard_D2s_v3"
instances     = 3
admin_username = "azureuser"
subnet_name   = "snet-vm"
upgrade_mode  = "RollingUpgrade"
