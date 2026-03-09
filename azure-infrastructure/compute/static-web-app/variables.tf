variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "sku_tier" {
  type        = string
  default     = "Free"
  description = "Free ($0) or Standard ($9/mo). Standard adds private endpoints and SLA."
}

variable "sku_size" {
  type    = string
  default = "Free"
}
