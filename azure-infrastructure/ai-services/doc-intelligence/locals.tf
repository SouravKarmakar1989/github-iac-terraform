locals {
  name_prefix = "${var.prefix}-${var.env}"

  sa_name = substr(lower(replace("${var.prefix}${var.env}docintel", "-", "")), 0, 24)

  common_tags = {
    env        = var.env
    module     = "doc-intelligence"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
