variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "pool_allocation_mode" {
  type        = string
  default     = "BatchService"
  description = "BatchService (default) or UserSubscription (requires key vault)."
}
