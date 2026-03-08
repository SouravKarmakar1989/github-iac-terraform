output "storage_account_id"          { value = azurerm_storage_account.sa.id }
output "storage_account_name"        { value = azurerm_storage_account.sa.name }
output "share_name"                  { value = azurerm_storage_share.share.name }
output "primary_file_endpoint"       { value = azurerm_storage_account.sa.primary_file_endpoint }
output "primary_connection_string"   { value = azurerm_storage_account.sa.primary_connection_string; sensitive = true }
