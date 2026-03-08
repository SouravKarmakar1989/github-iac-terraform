variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "synapse_sql_admin" {
  type    = string
  default = "sqladmin"
}

variable "synapse_sql_password" {
  type        = string
  sensitive   = true
  description = "Must meet Azure complexity: upper, lower, digit, special char, 8+ chars."
}

variable "enable_stream_analytics" {
  type        = bool
  default     = false
  description = "Stream Analytics: ~$80/SU/month when RUNNING, $0 when stopped. Enable only when needed."
}
