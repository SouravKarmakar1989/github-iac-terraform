variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "container_image" {
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
  description = "Container image to deploy."
}

variable "container_cpu" {
  type    = number
  default = 0.25
}

variable "container_memory" {
  type    = string
  default = "0.5Gi"
}

variable "min_replicas" {
  type    = number
  default = 0
  description = "Set to 0 for scale-to-zero (no idle charge)."
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "ingress_external" {
  type    = bool
  default = true
}
