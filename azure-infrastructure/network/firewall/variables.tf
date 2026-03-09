variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

# ── Network core remote state ─────────────────────────────────────────────────
variable "network_core_state_resource_group_name"  { type = string }
variable "network_core_state_storage_account_name" { type = string }
variable "network_core_state_container_name"       { type = string }
variable "network_core_state_key"                  { type = string }

# ── Firewall config ───────────────────────────────────────────────────────────
variable "sku_name" {
  type        = string
  default     = "AZFW_VNet"
  description = "AZFW_VNet (standard VNet deployment) or AZFW_Hub (Virtual WAN hub)."
}

variable "sku_tier" {
  type        = string
  default     = "Standard"
  description = "Basic (~$312/mo), Standard (~$875/mo), Premium (~$1,252/mo). Basic is v2 only."
}

variable "threat_intel_mode" {
  type        = string
  default     = "Alert"
  description = "Off, Alert, or Deny."
}
