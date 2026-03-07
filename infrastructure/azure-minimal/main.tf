resource "random_string" "suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

import {
  to = azurerm_resource_group.lab
  id = "/subscriptions/d43789e3-9b65-4b52-8737-c279a4e40a69/resourceGroups/rg-lab-dev"
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

  tags = {
    env     = var.env
    purpose = "azure-minimal-smoketest"
  }
}

resource "azurerm_storage_container" "c" {
  name                  = "smoketest"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
