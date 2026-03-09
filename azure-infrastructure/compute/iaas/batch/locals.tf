locals {
  name_prefix = "${var.prefix}-${var.env}"
  # Batch account name: 3-24 chars, lowercase alphanumeric only
  batch_name = lower(replace("${var.prefix}${var.env}batch", "-", ""))

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "compute/iaas/batch"
  }
}
