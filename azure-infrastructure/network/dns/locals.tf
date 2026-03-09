locals {
  name_prefix = "${var.prefix}-${var.env}"

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "network/dns"
  }
}
