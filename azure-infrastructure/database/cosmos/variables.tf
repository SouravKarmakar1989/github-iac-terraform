variable "location"   { type = string }
variable "env"        { type = string }
variable "prefix"     { type = string }

variable "enable_free_tier" {
  type        = bool
  default     = true
  description = "⚠️ Only ONE free-tier Cosmos DB account per Azure subscription. Provides 1000 RU/s + 25 GB free."
}

variable "database_name" {
  type    = string
  default = "appdb"
}

variable "container_name" {
  type    = string
  default = "items"
}

variable "partition_key_path" {
  type        = string
  default     = "/id"
  description = "Partition key for the SQL container."
}
