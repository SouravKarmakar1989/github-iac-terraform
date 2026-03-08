locals {
  name_prefix = "${var.prefix}-${var.env}"
  sa_name     = "${replace(local.name_prefix, "-", "")}file"

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "storage-files"
  }
}
