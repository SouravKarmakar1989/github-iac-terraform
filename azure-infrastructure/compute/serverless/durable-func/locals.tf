locals {
  name_prefix       = "${var.prefix}-${var.env}"
  storage_host_name = lower(replace("${var.prefix}${var.env}dfhost", "-", ""))
  storage_dur_name  = lower(replace("${var.prefix}${var.env}dfstate", "-", ""))

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "compute/serverless/durable-func"
  }
}
