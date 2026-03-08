output "frontdoor_profile_id"   { value = azurerm_cdn_frontdoor_profile.afd.id }
output "frontdoor_profile_name" { value = azurerm_cdn_frontdoor_profile.afd.name }
output "endpoint_hostname"      { value = azurerm_cdn_frontdoor_endpoint.endpoint.host_name }
