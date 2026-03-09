variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

# ── Network remote state ──────────────────────────────────────────────────────
variable "network_state_resource_group_name"  { type = string }
variable "network_state_storage_account_name" { type = string }
variable "network_state_container_name"       { type = string }
variable "network_state_key"                  { type = string }

# ── VM config ─────────────────────────────────────────────────────────────────
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH public key content. Leave empty to use password auth."
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "subnet_name" {
  type    = string
  default = "snet-vm"
}

variable "os_disk_type" {
  type    = string
  default = "Standard_LRS"
}
