variable "location"        { type = string }
variable "env"             { type = string }
variable "prefix"          { type = string }
variable "publisher_name"  { type = string; description = "Name of the API publisher / organisation" }
variable "publisher_email" { type = string; description = "Contact email for the API publisher" }

variable "sku_name" {
  type        = string
  default     = "Developer_1"
  description = "SKU of the APIM instance. Format: <tier>_<capacity> e.g. Developer_1, Basic_1, Standard_1, Premium_1"
}
