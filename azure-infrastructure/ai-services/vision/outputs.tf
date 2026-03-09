output "resource_group_name"  { value = azurerm_resource_group.vision.name }
output "vision_endpoint"      { value = azurerm_cognitive_account.vision.endpoint }
output "vision_principal_id"  { value = azurerm_cognitive_account.vision.identity[0].principal_id }
output "vision_account_id"    { value = azurerm_cognitive_account.vision.id }
