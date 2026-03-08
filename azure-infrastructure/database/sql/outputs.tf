output "server_id"             { value = azurerm_mssql_server.sql.id }
output "server_fqdn"           { value = azurerm_mssql_server.sql.fully_qualified_domain_name }
output "server_principal_id"   { value = azurerm_mssql_server.sql.identity[0].principal_id }
output "database_id"           { value = azurerm_mssql_database.db.id }
output "database_name"         { value = azurerm_mssql_database.db.name }
