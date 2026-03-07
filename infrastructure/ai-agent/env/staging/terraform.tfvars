prefix                  = "sk"
location                = "eastus"
env                     = "staging"

agent_model_capacity    = 40
embedding_capacity      = 60

search_sku              = "standard"

container_cpu           = 1.0
container_memory        = "2Gi"
min_replicas            = 1
max_replicas            = 5

container_image         = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
