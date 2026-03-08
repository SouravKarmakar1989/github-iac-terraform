output "openai_endpoint"           { value = azurerm_cognitive_account.openai.endpoint }
output "openai_principal_id"       { value = azurerm_cognitive_account.openai.identity[0].principal_id }
output "agent_model_deployment"    { value = azurerm_cognitive_deployment.agent_model.name }
output "embedding_deployment"      { value = azurerm_cognitive_deployment.embedding.name }
output "container_app_fqdn"        { value = azurerm_container_app.agent.ingress[0].fqdn }
output "container_app_principal_id"{ value = azurerm_container_app.agent.identity[0].principal_id }
output "agent_state_container"     { value = "${azurerm_storage_account.agent.primary_blob_endpoint}${azurerm_storage_container.state.name}" }
