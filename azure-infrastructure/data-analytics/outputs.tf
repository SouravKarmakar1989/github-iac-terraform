output "synapse_workspace_id"           { value = azurerm_synapse_workspace.synapse.id }
output "synapse_connectivity_endpoints"  { value = azurerm_synapse_workspace.synapse.connectivity_endpoints }
output "synapse_principal_id"            { value = azurerm_synapse_workspace.synapse.identity[0].principal_id }
output "adls_primary_dfs_endpoint"       { value = azurerm_storage_account.adls.primary_dfs_endpoint }
output "adls_id"                         { value = azurerm_storage_account.adls.id }
output "stream_analytics_job_id"         { value = try(azurerm_stream_analytics_job.asa[0].id, null) }
