locals {
  name_prefix = "${var.prefix}-${var.env}"

  sa_name = substr(lower(replace("${var.prefix}${var.env}genai", "-", "")), 0, 24)

  common_tags = {
    env        = var.env
    module     = "genAI-agentic"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
