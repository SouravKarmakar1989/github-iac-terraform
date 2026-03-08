variable "location"   { type = string }
variable "env"        { type = string }
variable "prefix"     { type = string }

variable "sql_admin" {
  type    = string
  default = "sqladmin"
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "use_free_tier" {
  type        = bool
  default     = true
  description = "⚠️ Only ONE Azure SQL free offer per subscription. 100K vCore-seconds + 32 GB free/month. When exhausted, compute auto-pauses."
}
