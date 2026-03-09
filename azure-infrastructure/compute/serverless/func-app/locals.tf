locals {
  name_prefix = "${var.prefix}-${var.env}"
  # Storage account name: 3-24 chars, lowercase alphanumeric only
  storage_name = lower(replace("${var.prefix}${var.env}func", "-", ""))

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "compute/serverless/func-app"
  }
}
