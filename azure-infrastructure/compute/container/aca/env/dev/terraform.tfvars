prefix   = "sk"
location = "eastus"
env      = "dev"

container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_cpu    = 0.25
container_memory = "0.5Gi"
min_replicas     = 0
max_replicas     = 3
ingress_external = true
