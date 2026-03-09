# network/firewall — Azure Firewall
# Cost: Standard ~$875/mo | Basic ~$312/mo | Premium ~$1,252/mo (excludes data processing).
# Prerequisites:
#   1. network/core must be deployed first.
#   2. network/core subnets map MUST include:
#      AzureFirewallSubnet = { address_prefix = "10.x.x.x/26" }   # /26 minimum
# Tip: Use Forced Tunneling or Firewall Policy (azurerm_firewall_policy) to manage rules.

data "terraform_remote_state" "network_core" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.network_core_state_resource_group_name
    storage_account_name = var.network_core_state_storage_account_name
    container_name       = var.network_core_state_container_name
    key                  = var.network_core_state_key
  }
}

resource "azurerm_public_ip" "fw_pip" {
  name                = "${local.name_prefix}-pip-fw"
  resource_group_name = data.terraform_remote_state.network_core.outputs.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_firewall" "fw" {
  name                = "${local.name_prefix}-fw"
  resource_group_name = data.terraform_remote_state.network_core.outputs.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  threat_intel_mode   = var.threat_intel_mode

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = data.terraform_remote_state.network_core.outputs.subnet_ids["AzureFirewallSubnet"]
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }

  tags = local.common_tags
}
