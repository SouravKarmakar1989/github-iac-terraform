variable "location"                   { type = string }
variable "env"                        { type = string }
variable "prefix"                     { type = string }
variable "log_analytics_workspace_id" { type = string; description = "Resource ID of the shared Log Analytics workspace" }

variable "speech_sku" {
  type        = string
  default     = "S0"
  description = "SKU for Azure AI Speech service"
}

variable "language_sku" {
  type        = string
  default     = "S"
  description = "SKU for Azure AI Language (Text Analytics)"
}
