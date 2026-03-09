variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "sku_name" {
  type        = string
  default     = "WS1"
  description = "WS1 (~$185/mo), WS2 (~$295/mo), WS3 (~$590/mo)."
}

variable "storage_replication_type" {
  type    = string
  default = "LRS"
}
