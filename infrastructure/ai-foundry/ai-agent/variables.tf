variable "location"    { type = string }
variable "env"         { type = string }
variable "prefix"      { type = string }

# ── OpenAI ────────────────────────────────────────────────────────────────────
variable "openai_sku" {
  type    = string
  default = "S0"
}

variable "agent_model" {
  type        = string
  default     = "gpt-4o"
  description = "Model used by the agent — must support function calling / tool use"
}

variable "agent_model_version" {
  type    = string
  default = "2024-08-06"
}

variable "agent_model_capacity" {
  type    = number
  default = 20
  description = "TPM capacity in thousands"
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
  description = "Container image for the agent. Replace with your agent image."
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
  default = 0  # Scale to zero when idle
}

variable "max_replicas" {
  type    = number
  default = 3
}
