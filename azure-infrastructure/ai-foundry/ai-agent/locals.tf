locals {
  name_prefix = "${var.prefix}-${var.env}"

  sa_name = substr(lower(replace("${var.prefix}${var.env}agent", "-", "")), 0, 24)

  common_tags = {
    env        = var.env
    module     = "ai-agent"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
    exam       = "AI-102"
  }
}
