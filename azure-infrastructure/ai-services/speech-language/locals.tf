locals {
  name_prefix = "${var.prefix}-${var.env}"

  common_tags = {
    env        = var.env
    module     = "speech-language"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
