output "logic_app_standard_id" {
  value = azurerm_logic_app_standard.las.id
}

output "logic_app_standard_name" {
  value = azurerm_logic_app_standard.las.name
}

output "logic_app_url" {
  value = azurerm_logic_app_standard.las.custom_domain_verification_id
}

output "resource_group_name" {
  value = azurerm_resource_group.las.name
}
