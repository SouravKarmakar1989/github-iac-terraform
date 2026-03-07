resource "azurerm_resource_group" "dbx" {
  name     = "${local.name_prefix}-rg-databricks"
  location = var.location
  tags     = local.common_tags
}

# ── Databricks Workspace ──────────────────────────────────────────────────────
# Zero cost at rest — charges only occur when compute clusters are running.
# SKU options:
#   trial    = 14-day premium trial (no cluster charge), then auto-converts to standard
#   standard = Collaborative notebooks, jobs, ML experiments
#   premium  = Unity Catalog, row/column-level security, fine-grained access control
#
# No clusters are defined here — create them on demand via the Databricks UI
# or add azurerm_databricks_* / databricks_cluster resources when needed.

resource "azurerm_databricks_workspace" "dbx" {
  name                = "${local.name_prefix}-dbx"
  resource_group_name = azurerm_resource_group.dbx.name
  location            = azurerm_resource_group.dbx.location
  sku                 = var.sku
  tags                = local.common_tags
}
