output "resource_group_name"  { value = azurerm_resource_group.ai_search.name }
output "search_service_name"  { value = azurerm_search_service.search.name }
output "search_endpoint"      { value = "https://${azurerm_search_service.search.name}.search.windows.net" }
output "search_principal_id"  { value = azurerm_search_service.search.identity[0].principal_id }
output "search_service_id"    { value = azurerm_search_service.search.id }
