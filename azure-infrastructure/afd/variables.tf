variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "sku_name" {
  type    = string
  default = "Standard_AzureFrontDoor"
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "sku_name must be Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "origin_host_name" {
  type        = string
  description = "Hostname of the backend origin (e.g. myapp.azurewebsites.net)"
}
