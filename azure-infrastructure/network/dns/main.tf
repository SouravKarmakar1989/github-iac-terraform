# network/dns — Azure Private DNS Zones + optional Public DNS Zones
# Cost: Private DNS - $0.50/zone/month + $0.40/million queries.
#       Public DNS  - $0.90/zone/month + $0.40/million queries.
#
# Private DNS zones are linked to the VNet from network/core state.
# Common private DNS zones for Azure PaaS private endpoints:
#   privatelink.blob.core.windows.net
#   privatelink.database.windows.net
#   privatelink.vaultcore.azure.net
#   privatelink.azurecr.io
#   privatelink.servicebus.windows.net

data "terraform_remote_state" "network_core" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.network_core_state_resource_group_name
    storage_account_name = var.network_core_state_storage_account_name
    container_name       = var.network_core_state_container_name
    key                  = var.network_core_state_key
  }
}

resource "azurerm_resource_group" "dns" {
  name     = "${local.name_prefix}-rg-dns"
  location = var.location
  tags     = local.common_tags
}

# ── Private DNS Zones ─────────────────────────────────────────────────────────
resource "azurerm_private_dns_zone" "zone" {
  for_each            = toset(var.private_dns_zones)
  name                = each.value
  resource_group_name = azurerm_resource_group.dns.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  for_each              = toset(var.private_dns_zones)
  name                  = "${local.name_prefix}-link-${replace(each.value, ".", "-")}"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.zone[each.value].name
  virtual_network_id    = data.terraform_remote_state.network_core.outputs.vnet_id
  registration_enabled  = var.enable_auto_registration
  tags                  = local.common_tags
}

# ── Public DNS Zones ──────────────────────────────────────────────────────────
resource "azurerm_dns_zone" "public" {
  for_each            = toset(var.public_dns_zones)
  name                = each.value
  resource_group_name = azurerm_resource_group.dns.name
  tags                = local.common_tags
}
