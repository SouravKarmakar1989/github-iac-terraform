locals {
  name_prefix = "${var.prefix}-${var.env}"

  # Storage account name for document store
  sa_name = substr(lower(replace("${var.prefix}${var.env}genai", "-", "")), 0, 24)

  common_tags = {
    env        = var.env
    module     = "ai-genai"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
    exam       = "AI-102"
  }
}
