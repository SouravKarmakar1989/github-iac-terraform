output "private_dns_zone_ids" {
  description = "Map of private DNS zone name → resource ID."
  value       = { for k, v in azurerm_private_dns_zone.zone : k => v.id }
}

output "public_dns_zone_ids" {
  description = "Map of public DNS zone name → resource ID."
  value       = { for k, v in azurerm_dns_zone.public : k => v.id }
}

output "public_dns_name_servers" {
  description = "Map of public DNS zone name → name servers."
  value       = { for k, v in azurerm_dns_zone.public : k => v.name_servers }
}

output "resource_group_name" {
  value = azurerm_resource_group.dns.name
}
