variable "location"                   { type = string }
variable "env"                        { type = string }
variable "prefix"                     { type = string }
variable "resource_group_name"        { type = string; description = "Resource group name — typically output from log-analytics module" }
variable "log_analytics_workspace_id" { type = string; description = "Resource ID of the shared Log Analytics workspace (output from log-analytics module)" }

variable "application_type" {
  type        = string
  default     = "web"
  description = "Application type: web, ios, java, MobileCenter, Node.JS, other, phone, store"
}
