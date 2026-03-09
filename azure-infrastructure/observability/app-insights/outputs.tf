output "app_insights_id"                  { value = azurerm_application_insights.appi.id }
output "app_insights_name"                { value = azurerm_application_insights.appi.name }
output "connection_string"                { value = azurerm_application_insights.appi.connection_string; sensitive = true }
output "instrumentation_key"             { value = azurerm_application_insights.appi.instrumentation_key; sensitive = true }
output "app_insights_app_id"             { value = azurerm_application_insights.appi.app_id }
