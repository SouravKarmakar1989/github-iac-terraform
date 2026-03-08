variable "location"   { type = string }
variable "env"        { type = string }
variable "prefix"     { type = string }

variable "filesystems" {
  type        = list(string)
  default     = ["raw", "processed", "curated"]
  description = "ADLS Gen2 filesystem (container) names. Typical data lake zones: raw → processed → curated."
}
