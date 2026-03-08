resource "azurerm_resource_group" "afd" {
  name     = "${local.name_prefix}-rg-afd"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_cdn_frontdoor_profile" "afd" {
  name                = "${local.name_prefix}-afd"
  resource_group_name = azurerm_resource_group.afd.name
  sku_name            = var.sku_name
  tags                = local.common_tags
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "${local.name_prefix}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
  tags                     = local.common_tags
}

resource "azurerm_cdn_frontdoor_origin_group" "og" {
  name                     = "${local.name_prefix}-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id

  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "origin" {
  name                           = "${local.name_prefix}-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.og.id
  host_name                      = var.origin_host_name
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.origin_host_name
  priority                       = 1
  weight                         = 1000
  enabled                        = true
  certificate_name_check_enabled = false
}
