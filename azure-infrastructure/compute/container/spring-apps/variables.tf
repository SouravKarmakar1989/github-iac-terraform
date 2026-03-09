variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "sku_name" {
  type        = string
  default     = "S0"
  description = "B0 (Basic, ~$25/mo), S0 (Standard, ~$100/mo), E0 (Enterprise, higher)."
}
