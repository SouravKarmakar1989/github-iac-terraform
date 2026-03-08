variable "location"   { type = string }
variable "env"        { type = string }
variable "prefix"     { type = string }

variable "containers" {
  type        = list(string)
  default     = ["data"]
  description = "Container names to create (all private, no anonymous access)"
}
