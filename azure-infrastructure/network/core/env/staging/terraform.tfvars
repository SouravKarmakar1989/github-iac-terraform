prefix   = "sk"
location = "eastus"
env      = "staging"

vnet_address_space = ["10.1.0.0/16"]

subnets = {
  snet-vm  = { address_prefix = "10.1.1.0/24" }
  snet-aks = { address_prefix = "10.1.2.0/24" }
  snet-app = { address_prefix = "10.1.3.0/24" }
}

enable_nsg = true
