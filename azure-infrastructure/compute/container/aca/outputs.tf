output "container_app_fqdn" {
  value = azurerm_container_app.app.ingress[0].fqdn
}

output "container_app_id" {
  value = azurerm_container_app.app.id
}

output "environment_id" {
  value = azurerm_container_app_environment.env.id
}

output "resource_group_name" {
  value = azurerm_resource_group.aca.name
}
