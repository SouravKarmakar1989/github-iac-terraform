output "function_app_id"        { value = azurerm_linux_function_app.func.id }
output "function_app_name"      { value = azurerm_linux_function_app.func.name }
output "default_hostname"       { value = azurerm_linux_function_app.func.default_hostname }
output "outbound_ip_addresses"  { value = azurerm_linux_function_app.func.outbound_ip_addresses }
output "principal_id"           { value = azurerm_linux_function_app.func.identity[0].principal_id }
