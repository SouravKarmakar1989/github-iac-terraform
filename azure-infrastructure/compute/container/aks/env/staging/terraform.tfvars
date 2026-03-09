prefix   = "sk"
location = "eastus"
env      = "staging"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/staging.tfstate"

kubernetes_version = "1.30"
sku_tier           = "Standard"
node_vm_size       = "Standard_D4s_v3"
node_count         = 2
subnet_name        = "snet-aks"
