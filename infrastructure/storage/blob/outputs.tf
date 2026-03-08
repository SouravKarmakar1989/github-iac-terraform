output "storage_account_id"            { value = azurerm_storage_account.sa.id }
output "storage_account_name"          { value = azurerm_storage_account.sa.name }
output "primary_blob_endpoint"         { value = azurerm_storage_account.sa.primary_blob_endpoint }
output "primary_connection_string"     { value = azurerm_storage_account.sa.primary_connection_string; sensitive = true }
output "container_names"               { value = keys(azurerm_storage_container.containers) }
