output "lab_rg" { value = azurerm_resource_group.lab.name }
output "storage_account" { value = azurerm_storage_account.sa.name }
output "container" { value = azurerm_storage_container.c.name }
