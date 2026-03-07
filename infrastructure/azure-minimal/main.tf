resource "random_string" "suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "lab" {
  name     = var.lab_rg_name
  location = var.location
}

locals {
  sa_name = substr(lower(replace("${var.prefix}${var.env}${random_string.suffix.result}", "-", "")), 0, 24)
}

resource "azurerm_storage_account" "sa" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = merge(local.common_tags, {
    purpose = "azure-minimal-smoketest"
  })
}

resource "azurerm_storage_container" "c" {
  name                  = "smoketest"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
