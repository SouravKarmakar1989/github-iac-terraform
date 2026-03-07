variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

# ── App Service ───────────────────────────────────────────────────────────────
variable "app_service_sku" {
  type        = string
  default     = "F1"
  description = "F1=Free($0), B1=Basic(~$13/mo), S1=Standard(~$56/mo), P1v3=Premium(~$115/mo), P0v3=PremiumMicro(~$38/mo)"
}

variable "app_service_os" {
  type        = string
  default     = "Linux"
  description = "Linux or Windows"
}

# ── Container Registry ────────────────────────────────────────────────────────
variable "acr_sku" {
  type        = string
  default     = "Basic"
  description = "Basic ~$5/mo, Standard ~$20/mo, Premium ~$50/mo. No free tier."
}

# ── Container Apps ────────────────────────────────────────────────────────────
variable "enable_aca" {
  type        = bool
  default     = true
  description = "Consumption plan scales to zero — $0 when idle."
}

variable "aca_image" {
  type    = string
  default = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

# ── Azure Batch ───────────────────────────────────────────────────────────────
variable "enable_batch" {
  type        = bool
  default     = true
  description = "Batch account creation is $0. Pay only when compute pools are allocated."
}

# ── Virtual Machine ───────────────────────────────────────────────────────────
variable "enable_vm" {
  type        = bool
  default     = false
  description = "B1s ~$7/mo when running. OS disk ~$1.5/mo even when deallocated. Disabled by default."
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH public key content. If empty, vm_admin_password is used instead."
}

variable "vm_admin_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "Required when vm_ssh_public_key is empty and enable_vm = true."
}

# ── Azure Container Instances ─────────────────────────────────────────────────
variable "enable_aci" {
  type        = bool
  default     = false
  description = "ACI charges per vCPU-second and GB-second while running. Disabled by default."
}

variable "aci_image" {
  type    = string
  default = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
}

variable "aci_cpu" {
  type    = number
  default = 0.5
}

variable "aci_memory" {
  type        = string
  default     = "0.5"
  description = "Memory in GB"
}

# ── AKS ───────────────────────────────────────────────────────────────────────
variable "enable_aks" {
  type        = bool
  default     = false
  description = "AKS control plane is free (sku_tier=Free). Nodes pay per VM hour. Disabled by default."
}

variable "aks_node_size" {
  type    = string
  default = "Standard_B2s"
}

variable "aks_node_count" {
  type    = number
  default = 1
}
