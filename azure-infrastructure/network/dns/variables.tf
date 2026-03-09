variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

# ── Network core remote state ─────────────────────────────────────────────────
variable "network_core_state_resource_group_name"  { type = string }
variable "network_core_state_storage_account_name" { type = string }
variable "network_core_state_container_name"       { type = string }
variable "network_core_state_key"                  { type = string }

# ── Private DNS ───────────────────────────────────────────────────────────────
variable "private_dns_zones" {
  type        = list(string)
  default     = ["privatelink.blob.core.windows.net"]
  description = "List of private DNS zone names to create and link to the VNet."
}

variable "enable_auto_registration" {
  type        = bool
  default     = false
  description = "Auto-register VMs in the private DNS zone (only one zone per VNet can use this)."
}

# ── Public DNS ────────────────────────────────────────────────────────────────
variable "public_dns_zones" {
  type        = list(string)
  default     = []
  description = "List of public DNS zone names (e.g. 'example.com'). Leave empty to skip."
}
