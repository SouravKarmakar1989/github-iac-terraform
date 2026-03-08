resource "azurerm_resource_group" "adls" {
  name     = "${local.name_prefix}-rg-adls"
  location = var.location
  tags     = local.common_tags
}

# ── ADLS Gen2 — Standalone Data Lake ─────────────────────────────────────────
# HNS (Hierarchical Namespace) = ADLS Gen2. Same pricing as blob (~$0.018/GB/month).
# Effectively $0 when empty.
#
# AI Foundry overlap (IMPORTANT):
#   The 'data-analytics' module also provisions ADLS Gen2 as Synapse's primary
#   storage. If you want a single shared data lake, deploy THIS module and
#   reference its output in data-analytics via:
#     data "terraform_remote_state" "adls" {
#       backend = "azurerm"
#       config  = { ... key = "storage/adls/dev.tfstate" }
#     }
#   Then pass data.terraform_remote_state.adls.outputs.filesystem_id to
#   azurerm_synapse_workspace.storage_data_lake_gen2_filesystem_id.
#
#   Similarly, ai-foundry/ai-genai's document storage could reference this
#   ADLS account instead of its own Storage Account.

resource "azurerm_storage_account" "adls" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.adls.name
  location                        = azurerm_resource_group.adls.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true  # Hierarchical Namespace = ADLS Gen2
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "fs" {
  for_each           = toset(var.filesystems)
  name               = each.value
  storage_account_id = azurerm_storage_account.adls.id
}
