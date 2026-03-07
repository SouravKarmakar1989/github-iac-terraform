output "servicebus_id"              { value = azurerm_servicebus_namespace.sb.id }
output "servicebus_endpoint"        { value = azurerm_servicebus_namespace.sb.endpoint }
output "servicebus_principal_id"    { value = azurerm_servicebus_namespace.sb.identity[0].principal_id }
output "eventgrid_topic_endpoint"   { value = azurerm_eventgrid_topic.egt.endpoint }
output "logic_app_id"               { value = azurerm_logic_app_workflow.la.id }
output "logic_app_access_endpoint"  { value = azurerm_logic_app_workflow.la.access_endpoint }
output "logic_app_principal_id"     { value = azurerm_logic_app_workflow.la.identity[0].principal_id }
