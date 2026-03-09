output "vnet_id" {
  description = "Resource ID of the VNet."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the VNet."
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "Address space of the VNet."
  value       = azurerm_virtual_network.vnet.address_space
}

output "resource_group_name" {
  description = "Name of the network resource group."
  value       = azurerm_resource_group.network.name
}

output "subnet_ids" {
  description = "Map of subnet name → subnet resource ID."
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet name → subnet name (for reference)."
  value       = { for k, v in azurerm_subnet.subnets : k => v.name }
}
