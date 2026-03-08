variable "location"               { type = string }
variable "env"                    { type = string }
variable "prefix"                 { type = string }

variable "pg_admin" {
  type    = string
  default = "pgadmin"
}

variable "pg_admin_password" {
  type      = string
  sensitive = true
}

variable "pg_version" {
  type        = string
  default     = "16"
  description = "PostgreSQL version: 16, 15, 14, or 13"
}

variable "pg_sku" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "B_Standard_B1ms ~$12/mo (cheapest). No free tier exists for PostgreSQL Flexible Server."
}

variable "storage_mb" {
  type    = number
  default = 32768  # 32 GB minimum
}
