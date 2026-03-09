output "resource_group_name"        { value = azurerm_resource_group.content_und.name }
output "content_und_endpoint"       { value = azurerm_cognitive_account.content_und.endpoint }
output "content_und_principal_id"   { value = azurerm_cognitive_account.content_und.identity[0].principal_id }
output "content_und_account_id"     { value = azurerm_cognitive_account.content_und.id }
