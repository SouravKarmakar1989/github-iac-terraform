output "batch_account_name" {
  value = azurerm_batch_account.batch.name
}

output "batch_account_endpoint" {
  value = azurerm_batch_account.batch.account_endpoint
}

output "resource_group_name" {
  value = azurerm_resource_group.batch.name
}
