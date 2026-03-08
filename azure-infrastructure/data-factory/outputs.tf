output "factory_id"       { value = azurerm_data_factory.adf.id }
output "factory_name"     { value = azurerm_data_factory.adf.name }
output "principal_id"     { value = azurerm_data_factory.adf.identity[0].principal_id }
