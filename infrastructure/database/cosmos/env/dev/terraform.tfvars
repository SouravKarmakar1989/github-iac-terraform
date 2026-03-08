prefix            = "sk"
location          = "eastus"
env               = "dev"
enable_free_tier  = true   # Only 1 free-tier Cosmos DB per subscription
database_name     = "appdb"
container_name    = "items"
partition_key_path = "/id"
