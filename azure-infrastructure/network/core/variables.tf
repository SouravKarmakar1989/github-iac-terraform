variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Address space for the VNet."
}

# Subnets: map of name → address_prefix
# Consumers (compute/iaas/vm, compute/container/aks, etc.) reference outputs.subnet_ids by name.
variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
  default = {
    snet-vm  = { address_prefix = "10.0.1.0/24" }
    snet-aks = { address_prefix = "10.0.2.0/24" }
    snet-app = { address_prefix = "10.0.3.0/24" }
    # Add AzureFirewallSubnet here if deploying network/firewall
    # AzureFirewallSubnet = { address_prefix = "10.0.255.0/26" }
  }
  description = "Map of subnet name → address prefix."
}

variable "enable_nsg" {
  type        = bool
  default     = true
  description = "Create and associate a default-deny NSG on each subnet."
}
