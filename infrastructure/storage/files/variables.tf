variable "location"       { type = string }
variable "env"            { type = string }
variable "prefix"         { type = string }

variable "share_name" {
  type    = string
  default = "data"
}

variable "share_quota_gb" {
  type        = number
  default     = 5
  description = "Share size in GB. Standard LRS: ~$0.06/GB/month. 5 GB = ~$0.30/month."
}
