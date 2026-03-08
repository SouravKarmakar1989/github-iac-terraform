output "resource_group_name"       { value = azurerm_resource_group.ai.name }
output "cognitive_endpoint"         { value = azurerm_cognitive_account.ai.endpoint }
output "cognitive_principal_id"     { value = azurerm_cognitive_account.ai.identity[0].principal_id }
output "key_vault_id"               { value = azurerm_key_vault.kv.id }
output "key_vault_uri"              { value = azurerm_key_vault.kv.vault_uri }
output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.law.id }
output "app_insights_connection"    { value = azurerm_application_insights.appi.connection_string; sensitive = true }
output "app_insights_instrumentation_key" { value = azurerm_application_insights.appi.instrumentation_key; sensitive = true }
