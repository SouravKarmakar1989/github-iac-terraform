locals {
  name_prefix = "${var.prefix}-${var.env}"

  # Storage account name: prefix + env + "func", max 24 chars, lowercase alphanumeric only
  sa_name = substr(lower(replace("${var.prefix}${var.env}func", "-", "")), 0, 24)

  common_tags = {
    env        = var.env
    module     = "func-app"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
