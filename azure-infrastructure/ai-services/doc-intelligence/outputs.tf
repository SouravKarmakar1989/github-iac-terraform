output "resource_group_name"       { value = azurerm_resource_group.doc_intel.name }
output "doc_intel_endpoint"        { value = azurerm_cognitive_account.doc_intel.endpoint }
output "doc_intel_principal_id"    { value = azurerm_cognitive_account.doc_intel.identity[0].principal_id }
output "doc_intel_account_id"      { value = azurerm_cognitive_account.doc_intel.id }
output "storage_account_name"      { value = azurerm_storage_account.docs.name }
output "source_docs_container_url" { value = "${azurerm_storage_account.docs.primary_blob_endpoint}${azurerm_storage_container.source_docs.name}" }
