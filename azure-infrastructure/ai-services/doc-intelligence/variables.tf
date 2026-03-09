variable "location"                   { type = string }
variable "env"                        { type = string }
variable "prefix"                     { type = string }
variable "log_analytics_workspace_id" { type = string; description = "Resource ID of the shared Log Analytics workspace" }

variable "doc_intel_sku" {
  type        = string
  default     = "S0"
  description = "SKU for Azure AI Document Intelligence (FormRecognizer)"
}
