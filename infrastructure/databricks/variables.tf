variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "sku" {
  type        = string
  default     = "standard"
  description = "Workspace SKU: trial (14-day free premium then auto-converts to standard), standard, or premium. No per-workspace charge — you only pay DBUs when compute clusters are running."
}
