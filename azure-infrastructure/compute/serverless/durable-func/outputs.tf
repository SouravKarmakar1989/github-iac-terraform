output "function_app_name" {
  value = azurerm_linux_function_app.df.name
}

output "function_app_hostname" {
  value = azurerm_linux_function_app.df.default_hostname
}

output "durable_storage_account_name" {
  value = azurerm_storage_account.durable.name
}

output "resource_group_name" {
  value = azurerm_resource_group.df.name
}
