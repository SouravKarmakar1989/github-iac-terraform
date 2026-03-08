variable "location"        { type = string }
variable "env"             { type = string }
variable "prefix"          { type = string }

variable "os_type" {
  type    = string
  default = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be Linux or Windows."
  }
}

variable "sku_name" {
  type        = string
  default     = "Y1"
  description = "App Service Plan SKU. Y1 = Consumption, EP1/EP2/EP3 = Elastic Premium, B1/S1/P1v3 = Dedicated"
}

variable "runtime" {
  type    = string
  default = "python"
  description = "Function runtime: python, node, dotnet, java, powershell"
}

variable "runtime_version" {
  type    = string
  default = "3.11"
}
