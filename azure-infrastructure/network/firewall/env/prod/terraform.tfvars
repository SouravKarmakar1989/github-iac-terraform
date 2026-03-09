prefix   = "sk"
location = "eastus"
env      = "prod"

network_core_state_resource_group_name  = "rg-tfstate"
network_core_state_storage_account_name = "satfstate2301"
network_core_state_container_name       = "tfstate"
network_core_state_key                  = "network/core/prod.tfstate"

sku_name          = "AZFW_VNet"
sku_tier          = "Premium"
threat_intel_mode = "Deny"
