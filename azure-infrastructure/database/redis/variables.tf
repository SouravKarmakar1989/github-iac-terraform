variable "location"   { type = string }
variable "env"        { type = string }
variable "prefix"     { type = string }

variable "redis_capacity" {
  type        = number
  default     = 0
  description = "C0=0 (~$16/mo), C1=1 (~$80/mo). No free tier for Redis. C0 Basic: 250 MB cache, no SLA, no replication."
}

variable "redis_family" {
  type    = string
  default = "C"
  description = "C = Basic/Standard. P = Premium."
}

variable "redis_sku" {
  type    = string
  default = "Basic"
  description = "Basic: dev/test only, no SLA, no replication. Standard: replicated, SLA. Premium: advanced features."
}
