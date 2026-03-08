resource "azurerm_resource_group" "cosmos" {
  name     = "${local.name_prefix}-rg-cosmos"
  location = var.location
  tags     = local.common_tags
}

# ── Cosmos DB (NoSQL / SQL API) ───────────────────────────────────────────────
# Free tier: 1000 RU/s + 25 GB per month — permanently free (not a trial).
# ⚠️ Only ONE free-tier account allowed per Azure subscription.
# Cost without free tier: ~$0.008/RU-hour for provisioned + ~$0.25/GB/month storage.
#
# AI Foundry connection:
#   Cosmos DB makes an excellent vector-capable document store for agent memory
#   when combined with the Azure Cosmos DB for MongoDB API (vCore) or the
#   built-in vector search in NoSQL API (preview). If ai-foundry/ai-agent needs
#   persistent conversation history or tool state, reference this module's
#   outputs via terraform_remote_state instead of using a separate Storage Account.

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "${local.name_prefix}-cosmos"
  location            = azurerm_resource_group.cosmos.location
  resource_group_name = azurerm_resource_group.cosmos.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"  # SQL / NoSQL API
  enable_free_tier    = var.enable_free_tier

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Shared throughput database — 400 RU/s (within 1000 RU/s free allowance)
resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.database_name
  resource_group_name = azurerm_resource_group.cosmos.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = var.container_name
  resource_group_name = azurerm_resource_group.cosmos.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = var.partition_key_path
  # No throughput set — inherits database shared throughput (400 RU/s)
}
