resource "azurerm_resource_group" "storage" {
  name     = "${local.name_prefix}-rg-blob"
  location = var.location
  tags     = local.common_tags
}

# ── Blob Storage Account ──────────────────────────────────────────────────────
# Cost: ~$0.018/GB/month (Hot LRS). Effectively $0 when empty.
# Public access disabled — all containers are private.
# Outputs: primary_blob_endpoint is exposed for reference by other modules
# (e.g. ai-foundry modules can reference this via terraform_remote_state).
#
# AI Foundry overlap:
#   ai-foundry/ai-genai and ai-foundry/ai-agent each provision their own SA.
#   To centralise blob storage, deploy this module first and reference its
#   outputs via a data.terraform_remote_state block in the foundry modules.

resource "azurerm_storage_account" "sa" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.storage.name
  location                        = azurerm_resource_group.storage.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
