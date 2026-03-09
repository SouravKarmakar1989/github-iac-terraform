# policy/tags/mandatory_tags.rego
# ─────────────────────────────────────────────────────────────────────────────
# OPA (Open Policy Agent) policy — enforces mandatory tags on all resources.
# ─────────────────────────────────────────────────────────────────────────────
# Usage with Conftest (free, open source):
#   conftest test azure-infrastructure/security/key-vault/main.tf \
#     --policy policy/tags/ --parser=hcl2
#
# Add to CI by running:
#   conftest test <path> --policy policy/ --parser=hcl2 --no-color
# ─────────────────────────────────────────────────────────────────────────────

package terraform.tags

import future.keywords.contains
import future.keywords.if

# ── Mandatory tag keys every resource must have ───────────────────────────────
mandatory_tags := {"env", "managed_by", "repo"}

# ── Resources that are exempt (child resources inherit from parent) ───────────
exempt_resource_types := {
  "azurerm_cognitive_deployment",
  "azurerm_storage_container",
  "azurerm_monitor_diagnostic_setting",
  "azurerm_key_vault_secret",
  "azurerm_role_assignment",
}

# ── Violation rule ────────────────────────────────────────────────────────────
deny contains msg if {
  some resource_type, resource_name
  resource := input.resource[resource_type][resource_name]

  # Only check resources that support tags
  not exempt_resource_types[resource_type]
  resource.tags

  # Find any mandatory tag that is missing
  missing := mandatory_tags - {tag | resource.tags[tag]}
  count(missing) > 0

  msg := sprintf(
    "Resource '%s.%s' is missing mandatory tags: %v",
    [resource_type, resource_name, missing],
  )
}

# Warn (not deny) when 'module' tag is absent — helpful but not mandatory
warn contains msg if {
  some resource_type, resource_name
  resource := input.resource[resource_type][resource_name]
  not exempt_resource_types[resource_type]
  resource.tags
  not resource.tags.module

  msg := sprintf(
    "Resource '%s.%s' is missing recommended tag 'module'",
    [resource_type, resource_name],
  )
}
