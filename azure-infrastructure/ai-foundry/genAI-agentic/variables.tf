variable "location" { type = string }
variable "env"      { type = string }
variable "prefix"   { type = string }

# ── OpenAI ────────────────────────────────────────────────────────────────────

variable "openai_sku" {
  type    = string
  default = "S0"
}

variable "gpt_model" {
  type        = string
  default     = "gpt-4o"
  description = "Chat completion model — also serves as the agentic function-calling model"
}

variable "gpt_model_version" {
  type    = string
  default = "2024-08-06"
}

variable "gpt_capacity" {
  type        = number
  default     = 20
  description = "TPM capacity in thousands (e.g. 20 = 20K TPM)"
}

variable "embedding_model" {
  type    = string
  default = "text-embedding-ada-002"
}

variable "embedding_model_version" {
  type    = string
  default = "2"
}

variable "embedding_capacity" {
  type    = number
  default = 60
}

# ── Container Apps (agent runtime) ───────────────────────────────────────────

variable "container_image" {
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
  description = "Container image for the agent runtime. Replace with your agent image."
}

variable "container_cpu" {
  type    = number
  default = 0.5
}

variable "container_memory" {
  type    = string
  default = "1Gi"
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 5
}
