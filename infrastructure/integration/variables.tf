variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

variable "servicebus_sku" {
  type        = string
  default     = "Basic"
  description = "Basic: per-op pricing, no topics (queues only). Standard: $10/month base, adds topics/subscriptions. Premium: dedicated."
}
