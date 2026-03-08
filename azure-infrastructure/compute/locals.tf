locals {
  name_prefix = "${var.prefix}-${var.env}"

  # ACR: 5-50 chars, alphanumeric only
  acr_name = "${replace(local.name_prefix, "-", "")}acr"

  # Batch: 3-24 chars, lowercase alphanumeric only
  batch_name = "${replace(local.name_prefix, "-", "")}btch"

  # Networking is provisioned only when VM or AKS is enabled
  enable_networking = var.enable_vm || var.enable_aks

  # always_on must be false on F1 (Free) tier
  always_on = var.app_service_sku != "F1"

  common_tags = {
    env        = var.env
    managed_by = "terraform"
    module     = "compute"
  }
}
