# compute/iaas/batch — Azure Batch Account
# Cost: $0 to create and maintain at rest.
# Charges apply only while compute pool nodes are allocated (pay per VM-second).
# Pools and jobs are provisioned separately via the Batch API or additional resources.

resource "azurerm_resource_group" "batch" {
  name     = "${local.name_prefix}-rg-batch"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_batch_account" "batch" {
  name                 = local.batch_name
  resource_group_name  = azurerm_resource_group.batch.name
  location             = azurerm_resource_group.batch.location
  pool_allocation_mode = var.pool_allocation_mode
  tags                 = local.common_tags
}
