prefix   = "sk"
location = "eastus"
env      = "staging"

network_core_state_resource_group_name  = "rg-tfstate"
network_core_state_storage_account_name = "satfstate2301"
network_core_state_container_name       = "tfstate"
network_core_state_key                  = "network/core/staging.tfstate"

private_dns_zones = [
  "privatelink.blob.core.windows.net",
  "privatelink.database.windows.net",
  "privatelink.vaultcore.azure.net",
]

enable_auto_registration = false
public_dns_zones         = []
