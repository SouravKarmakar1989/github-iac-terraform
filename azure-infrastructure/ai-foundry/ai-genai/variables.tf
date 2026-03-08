variable "location"    { type = string }
variable "env"         { type = string }
variable "prefix"      { type = string }

# ── OpenAI ────────────────────────────────────────────────────────────────────
variable "openai_sku" {
  type    = string
  default = "S0"
}

variable "gpt_model" {
  type        = string
  default     = "gpt-4o"
  description = "OpenAI chat completion model name"
}

variable "gpt_model_version" {
  type    = string
  default = "2024-08-06"
}

variable "gpt_capacity" {
  type        = number
  default     = 10
  description = "Tokens-per-minute capacity in thousands (e.g. 10 = 10K TPM)"
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

# ── AI Search (RAG) ───────────────────────────────────────────────────────────
variable "search_sku" {
  type        = string
  default     = "basic"
  description = "AI Search SKU: free, basic, standard, standard2, standard3"
}
