locals {
  name_prefix = "${var.prefix}-${var.env}"

  # Key Vault name: max 24 chars, alphanumeric + hyphens
  kv_name = substr("${var.prefix}-${var.env}-kv-ai", 0, 24)

  common_tags = {
    env        = var.env
    module     = "ai-manage"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
    exam       = "AI-102"
  }
}
