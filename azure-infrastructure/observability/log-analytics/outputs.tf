output "resource_group_name"        { value = azurerm_resource_group.observability.name }
output "log_analytics_workspace_id"  { value = azurerm_log_analytics_workspace.law.id }
output "log_analytics_workspace_name"{ value = azurerm_log_analytics_workspace.law.name }
