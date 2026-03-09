# .tflint.hcl
# ─────────────────────────────────────────────────────────────────────────────
# tflint configuration — used by pre-commit and CI tf-lint job.
# Docs: https://github.com/terraform-linters/tflint
# ─────────────────────────────────────────────────────────────────────────────

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# ── Rules ─────────────────────────────────────────────────────────────────────

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = false   # we use our own naming convention via locals.name_prefix
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}
