variable "location"                   { type = string }
variable "env"                        { type = string }
variable "prefix"                     { type = string }
variable "log_analytics_workspace_id" { type = string; description = "Resource ID of the shared Log Analytics workspace" }

variable "search_sku" {
  type        = string
  default     = "basic"
  description = "AI Search SKU: free, basic, standard, standard2, standard3"
}

variable "semantic_search_sku" {
  type        = string
  default     = "free"
  description = "Semantic search SKU: free (1000 queries/month) or standard (unlimited)"
}
