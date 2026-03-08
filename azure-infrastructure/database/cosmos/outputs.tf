output "account_id"              { value = azurerm_cosmosdb_account.cosmos.id }
output "endpoint"                { value = azurerm_cosmosdb_account.cosmos.endpoint }
output "principal_id"            { value = azurerm_cosmosdb_account.cosmos.identity[0].principal_id }
output "primary_key"             { value = azurerm_cosmosdb_account.cosmos.primary_key; sensitive = true }
output "connection_strings"      { value = azurerm_cosmosdb_account.cosmos.connection_strings; sensitive = true }
output "database_name"           { value = azurerm_cosmosdb_sql_database.db.name }
output "container_name"          { value = azurerm_cosmosdb_sql_container.container.name }
