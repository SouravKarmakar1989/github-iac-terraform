variable "location"                  { type = string }
variable "env"                       { type = string }
variable "prefix"                    { type = string }
variable "log_analytics_workspace_id" { type = string; description = "Resource ID of the shared Log Analytics workspace" }

variable "vision_sku" {
  type        = string
  default     = "S1"
  description = "SKU for Azure AI Vision. S1 supports all features including spatial analysis."
}
