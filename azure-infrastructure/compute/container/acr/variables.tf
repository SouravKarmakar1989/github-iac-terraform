variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "sku" {
  type        = string
  default     = "Basic"
  description = "Basic (~$5/mo), Standard (~$20/mo), Premium (~$50/mo). Premium adds geo-replication and private endpoints."
}

variable "admin_enabled" {
  type    = bool
  default = false
}
