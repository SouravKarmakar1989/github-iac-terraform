output "app_service_plan_id" {
  value = azurerm_service_plan.plan.id
}

output "web_app_name" {
  value = var.os_type == "Linux" ? azurerm_linux_web_app.app[0].name : azurerm_windows_web_app.app[0].name
}

output "web_app_default_hostname" {
  value = var.os_type == "Linux" ? azurerm_linux_web_app.app[0].default_hostname : azurerm_windows_web_app.app[0].default_hostname
}

output "resource_group_name" {
  value = azurerm_resource_group.app.name
}
