prefix   = "sk"
location = "eastus"
env      = "staging"

network_core_state_resource_group_name  = "rg-tfstate"
network_core_state_storage_account_name = "satfstate2301"
network_core_state_container_name       = "tfstate"
network_core_state_key                  = "network/core/staging.tfstate"

sku_name          = "AZFW_VNet"
sku_tier          = "Standard"
threat_intel_mode = "Alert"
