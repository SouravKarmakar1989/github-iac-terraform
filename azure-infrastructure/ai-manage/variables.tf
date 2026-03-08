variable "location"        { type = string }
variable "env"             { type = string }
variable "prefix"          { type = string }
variable "tenant_id"       { type = string; description = "Azure AD tenant ID (for Key Vault access policies)" }

variable "cognitive_sku" {
  type        = string
  default     = "S0"
  description = "SKU for the multi-service Cognitive Services account"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "Log Analytics workspace data retention in days"
}

variable "log_analytics_sku" {
  type    = string
  default = "PerGB2018"
}
