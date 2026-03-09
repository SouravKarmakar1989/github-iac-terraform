variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

# ── App Service Plan ──────────────────────────────────────────────────────────
variable "sku_name" {
  type        = string
  default     = "F1"
  description = "SKU: F1 (free), B1 (~$13/mo), S1 (~$73/mo), P1v3 (~$139/mo), P0v3 (~$85/mo)."
}

variable "os_type" {
  type        = string
  default     = "Linux"
  description = "Linux or Windows."
}

# ── Web App ───────────────────────────────────────────────────────────────────
variable "runtime_stack" {
  type        = string
  default     = "NODE|20-lts"
  description = "Linux: 'NODE|20-lts', 'PYTHON|3.12', 'DOTNETCORE|8.0'. Windows: 'v4.0' (.NET), 'NODE|~20'."
}

variable "always_on" {
  type        = bool
  default     = false
  description = "Always-on requires at least B1. Must be false for F1."
}
