locals {
  name_prefix  = "${var.prefix}-${var.env}"
  storage_name = lower(replace("${var.prefix}${var.env}lasts", "-", ""))

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "compute/logic-app/standard"
  }
}
