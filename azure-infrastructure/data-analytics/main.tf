resource "azurerm_resource_group" "analytics" {
  name     = "${local.name_prefix}-rg-analytics"
  location = var.location
  tags     = local.common_tags
}

# ── ADLS Gen2 — Synapse primary storage ──────────────────────────────────────
# HNS (Hierarchical Namespace) = ADLS Gen2. Required by Synapse workspace.
# Cost: ~$0.018/GB/month (Standard LRS). $0 for queries — Synapse serverless
# charges $5/TB scanned, not on storage itself.

resource "azurerm_storage_account" "adls" {
  name                            = local.adls_name
  resource_group_name             = azurerm_resource_group.analytics.name
  location                        = azurerm_resource_group.analytics.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true  # Hierarchical Namespace = ADLS Gen2
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_fs" {
  name               = "synapse-data"
  storage_account_id = azurerm_storage_account.adls.id
}

# ── Synapse Analytics Workspace ───────────────────────────────────────────────
# Cost: workspace = $0. Serverless SQL pool = $5/TB scanned (no dedicated pool here).
# Dedicated SQL pool = very expensive — NOT created here. Enable only if needed.
# Spark pool = pay-per-vCore-hour when running — NOT created here.

resource "azurerm_synapse_workspace" "synapse" {
  name                                 = "${local.name_prefix}-synapse"
  resource_group_name                  = azurerm_resource_group.analytics.name
  location                             = azurerm_resource_group.analytics.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_fs.id
  sql_administrator_login              = var.synapse_sql_admin
  sql_administrator_login_password     = var.synapse_sql_password

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Allow Synapse managed identity to read/write the ADLS Gen2 account
resource "azurerm_role_assignment" "synapse_storage" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}

# ── Stream Analytics Job ──────────────────────────────────────────────────────
# Cost: $0 when stopped/paused. ~$80/month per Streaming Unit when RUNNING.
# Disabled by default (enable_stream_analytics = false).
# Start the job from the Azure portal or CLI when ready to process data.

resource "azurerm_stream_analytics_job" "asa" {
  count               = var.enable_stream_analytics ? 1 : 0
  name                = "${local.name_prefix}-asa"
  resource_group_name = azurerm_resource_group.analytics.name
  location            = azurerm_resource_group.analytics.location

  compatibility_level                      = "1.2"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 1

  # Placeholder query — replace with real input/output/query when configuring jobs
  transformation_query = "SELECT * INTO [YourOutputAlias] FROM [YourInputAlias]"

  tags = local.common_tags
}
