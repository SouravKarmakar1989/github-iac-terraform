output "openai_endpoint"          { value = azurerm_cognitive_account.openai.endpoint }
output "openai_principal_id"      { value = azurerm_cognitive_account.openai.identity[0].principal_id }
output "gpt_deployment_name"      { value = azurerm_cognitive_deployment.gpt.name }
output "embedding_deployment_name"{ value = azurerm_cognitive_deployment.embedding.name }
output "search_endpoint"          { value = "https://${azurerm_search_service.search.name}.search.windows.net" }
output "search_principal_id"      { value = azurerm_search_service.search.identity[0].principal_id }
output "documents_container_url"  { value = "${azurerm_storage_account.docs.primary_blob_endpoint}${azurerm_storage_container.documents.name}" }
