resource "azurerm_resource_group" "files" {
  name     = "${local.name_prefix}-rg-files"
  location = var.location
  tags     = local.common_tags
}

# ── Azure Files — SMB/NFS file share ─────────────────────────────────────────
# Standard LRS: ~$0.06/GB/month. Premium (SSD): ~$0.12/GB/month.
# Effectively $0 for a small dev share.
# Mount on Windows/Linux/macOS via SMB 3.x or NFS 4.1 (Premium only).

resource "azurerm_storage_account" "sa" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.files.name
  location                        = azurerm_resource_group.files.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_share" "share" {
  name                 = var.share_name
  storage_account_name = azurerm_storage_account.sa.name
  quota                = var.share_quota_gb
}
