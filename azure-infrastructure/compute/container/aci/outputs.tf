output "container_group_id" {
  value = azurerm_container_group.aci.id
}

output "fqdn" {
  value = azurerm_container_group.aci.fqdn
}

output "ip_address" {
  value = azurerm_container_group.aci.ip_address
}

output "resource_group_name" {
  value = azurerm_resource_group.aci.name
}
