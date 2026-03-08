variable "location"           { type = string }
variable "env"                { type = string }
variable "prefix"             { type = string }

variable "mysql_admin" {
  type    = string
  default = "mysqladmin"
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_version" {
  type        = string
  default     = "8.0.21"
  description = "MySQL version: 8.0.21 or 5.7"
}

variable "mysql_sku" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "B_Standard_B1ms ~$7.40/mo (cheapest). No free tier exists for MySQL Flexible Server."
}
