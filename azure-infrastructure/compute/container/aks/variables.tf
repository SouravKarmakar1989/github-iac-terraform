variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

# ── Network remote state ──────────────────────────────────────────────────────
variable "network_state_resource_group_name"  { type = string }
variable "network_state_storage_account_name" { type = string }
variable "network_state_container_name"       { type = string }
variable "network_state_key"                  { type = string }

# ── AKS config ────────────────────────────────────────────────────────────────
variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "sku_tier" {
  type        = string
  default     = "Free"
  description = "Free or Standard. Standard adds 99.95% SLA (~$73/mo per cluster)."
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "subnet_name" {
  type    = string
  default = "snet-aks"
}
