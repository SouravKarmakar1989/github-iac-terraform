locals {
  name_prefix = "${var.prefix}-${var.env}"

  common_tags = {
    env        = var.env
    module     = "vnet"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
