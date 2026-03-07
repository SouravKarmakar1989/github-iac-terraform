locals {
  name_prefix = "${var.prefix}-${var.env}"

  # Storage account: 3-24 chars, lowercase alphanumeric only
  adls_name = "${replace(local.name_prefix, "-", "")}adls"

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "data-analytics"
  }
}
