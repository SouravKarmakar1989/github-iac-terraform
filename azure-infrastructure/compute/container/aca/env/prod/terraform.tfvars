prefix   = "sk"
location = "eastus"
env      = "prod"

container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_cpu    = 1.0
container_memory = "2Gi"
min_replicas     = 2
max_replicas     = 10
ingress_external = true
