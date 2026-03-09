# policy/tags/mandatory_tags_test.rego
# Unit tests for the mandatory_tags policy.
# Run: conftest verify --policy policy/tags/

package terraform.tags_test

import data.terraform.tags

test_deny_missing_env_tag if {
  tags.deny["Resource 'azurerm_resource_group.test' is missing mandatory tags: {\"env\"}"] with input as {
    "resource": {
      "azurerm_resource_group": {
        "test": {
          "name": "my-rg",
          "location": "eastus",
          "tags": {
            "managed_by": "terraform",
            "repo": "github-iac-terraform",
          },
        },
      },
    },
  }
}

test_no_deny_when_all_tags_present if {
  count(tags.deny) == 0 with input as {
    "resource": {
      "azurerm_resource_group": {
        "test": {
          "name": "my-rg",
          "location": "eastus",
          "tags": {
            "env": "dev",
            "managed_by": "terraform",
            "repo": "github-iac-terraform",
          },
        },
      },
    },
  }
}

test_exempt_resource_not_checked if {
  count(tags.deny) == 0 with input as {
    "resource": {
      "azurerm_cognitive_deployment": {
        "gpt": {
          "name": "my-deployment",
          "cognitive_account_id": "/subscriptions/xxx",
        },
      },
    },
  }
}
