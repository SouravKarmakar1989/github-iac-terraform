output "logic_app_id" {
  value = azurerm_logic_app_workflow.la.id
}

output "logic_app_name" {
  value = azurerm_logic_app_workflow.la.name
}

output "access_endpoint" {
  value = azurerm_logic_app_workflow.la.access_endpoint
}

output "resource_group_name" {
  value = azurerm_resource_group.la.name
}
