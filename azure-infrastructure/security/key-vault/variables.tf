variable "location"                   { type = string }
variable "env"                        { type = string }
variable "prefix"                     { type = string }
variable "tenant_id"                  { type = string; description = "Azure AD tenant ID" }
variable "log_analytics_workspace_id" { type = string; description = "Resource ID of the shared Log Analytics workspace" }

variable "kv_sku" {
  type        = string
  default     = "standard"
  description = "Key Vault SKU: standard or premium (premium supports HSM-backed keys)"
}

variable "soft_delete_retention_days" {
  type        = number
  default     = 90
  description = "Days to retain soft-deleted vaults and objects (7–90)"
}

variable "purge_protection_enabled" {
  type        = bool
  default     = true
  description = "Prevents permanent deletion during retention period. Required for CMK scenarios."
}
