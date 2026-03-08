output "storage_account_id"    { value = azurerm_storage_account.adls.id }
output "storage_account_name"  { value = azurerm_storage_account.adls.name }
output "primary_dfs_endpoint"  { value = azurerm_storage_account.adls.primary_dfs_endpoint }
output "filesystem_ids"        { value = { for k, v in azurerm_storage_data_lake_gen2_filesystem.fs : k => v.id } }
# filesystem_id["raw"] — use this value in azurerm_synapse_workspace.storage_data_lake_gen2_filesystem_id
