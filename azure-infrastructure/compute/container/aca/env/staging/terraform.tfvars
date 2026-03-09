prefix   = "sk"
location = "eastus"
env      = "staging"

container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_cpu    = 0.5
container_memory = "1Gi"
min_replicas     = 1
max_replicas     = 5
ingress_external = true
