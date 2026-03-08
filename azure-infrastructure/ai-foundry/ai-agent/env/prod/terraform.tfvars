prefix                  = "sk"
location                = "eastus"
env                     = "prod"

agent_model_capacity    = 80
embedding_capacity      = 120

container_cpu           = 2.0
container_memory        = "4Gi"
min_replicas            = 2
max_replicas            = 10

container_image         = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
