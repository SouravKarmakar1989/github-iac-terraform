variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "log_analytics_sku" {
  type        = string
  default     = "PerGB2018"
  description = "Log Analytics workspace SKU"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "Data retention in days (30–730)"
}
