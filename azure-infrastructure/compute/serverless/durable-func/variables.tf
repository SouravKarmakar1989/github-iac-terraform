variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "runtime_version" {
  type    = string
  default = "20"
  description = "Node.js version for the Durable Functions host."
}

variable "storage_replication_type" {
  type    = string
  default = "LRS"
}
