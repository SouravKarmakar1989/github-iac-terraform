output "function_app_name" {
  value = var.os_type == "linux" ? azurerm_linux_function_app.func[0].name : azurerm_windows_function_app.func[0].name
}

output "function_app_hostname" {
  value = var.os_type == "linux" ? azurerm_linux_function_app.func[0].default_hostname : azurerm_windows_function_app.func[0].default_hostname
}

output "storage_account_name" {
  value = azurerm_storage_account.func.name
}

output "resource_group_name" {
  value = azurerm_resource_group.func.name
}
