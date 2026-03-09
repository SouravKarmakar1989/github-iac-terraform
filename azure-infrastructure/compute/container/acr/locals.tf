locals {
  name_prefix = "${var.prefix}-${var.env}"
  # ACR name: 5-50 chars, alphanumeric only
  acr_name = lower(replace("${var.prefix}${var.env}acr", "-", ""))

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "compute/container/acr"
  }
}
