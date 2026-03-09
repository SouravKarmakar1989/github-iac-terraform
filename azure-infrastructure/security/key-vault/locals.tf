locals {
  name_prefix = "${var.prefix}-${var.env}"

  # Key Vault name: max 24 chars, alphanumeric + hyphens
  kv_name = substr("${var.prefix}-${var.env}-kv", 0, 24)

  common_tags = {
    env        = var.env
    module     = "key-vault"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
