output "spring_cloud_id" {
  value = azurerm_spring_cloud_service.spring.id
}

output "spring_cloud_name" {
  value = azurerm_spring_cloud_service.spring.name
}

output "resource_group_name" {
  value = azurerm_resource_group.spring.name
}
