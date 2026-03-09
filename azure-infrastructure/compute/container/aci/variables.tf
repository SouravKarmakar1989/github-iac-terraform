variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "container_image" {
  type    = string
  default = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
}

variable "container_cpu" {
  type    = number
  default = 1.0
}

variable "container_memory" {
  type    = number
  default = 1.5
  description = "Memory in GB."
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "restart_policy" {
  type        = string
  default     = "Always"
  description = "Always, Never, or OnFailure."
}
