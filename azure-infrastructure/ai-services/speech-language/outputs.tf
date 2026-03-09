output "resource_group_name"    { value = azurerm_resource_group.speech_language.name }
output "speech_endpoint"        { value = azurerm_cognitive_account.speech.endpoint }
output "speech_principal_id"    { value = azurerm_cognitive_account.speech.identity[0].principal_id }
output "speech_account_id"      { value = azurerm_cognitive_account.speech.id }
output "language_endpoint"      { value = azurerm_cognitive_account.language.endpoint }
output "language_principal_id"  { value = azurerm_cognitive_account.language.identity[0].principal_id }
output "language_account_id"    { value = azurerm_cognitive_account.language.id }
