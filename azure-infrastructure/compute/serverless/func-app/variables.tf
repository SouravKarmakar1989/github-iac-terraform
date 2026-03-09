variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "os_type" {
  type        = string
  default     = "linux"
  description = "linux or windows."
}

variable "runtime" {
  type        = string
  default     = "node"
  description = "node, python, dotnet, java, powershell."
}

variable "runtime_version" {
  type    = string
  default = "20"
}

variable "storage_replication_type" {
  type    = string
  default = "LRS"
}
