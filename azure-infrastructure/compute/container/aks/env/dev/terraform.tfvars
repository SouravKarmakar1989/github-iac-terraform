prefix   = "sk"
location = "eastus"
env      = "dev"

network_state_resource_group_name  = "rg-tfstate"
network_state_storage_account_name = "satfstate2301"
network_state_container_name       = "tfstate"
network_state_key                  = "network/core/dev.tfstate"

kubernetes_version = "1.30"
sku_tier           = "Free"
node_vm_size       = "Standard_D2s_v3"
node_count         = 1
subnet_name        = "snet-aks"
