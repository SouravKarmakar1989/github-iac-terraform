resource "azurerm_resource_group" "compute" {
  name     = "${local.name_prefix}-rg-compute"
  location = var.location
  tags     = local.common_tags
}

# ── Log Analytics (shared — used by ACA and AKS) ──────────────────────────────
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name_prefix}-law-compute"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

# ── VNet + Subnets (provisioned only when VM or AKS is enabled) ───────────────
resource "azurerm_virtual_network" "vnet" {
  count               = local.enable_networking ? 1 : 0
  name                = "${local.name_prefix}-vnet-compute"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "vm_snet" {
  count                = var.enable_vm ? 1 : 0
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.compute.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_snet" {
  count                = var.enable_aks ? 1 : 0
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.compute.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = ["10.0.2.0/24"]
}

# ── App Service Plan + Web App ────────────────────────────────────────────────
# F1 = Free tier: truly $0 — 60 CPU min/day, 1 GB RAM, shared infrastructure.
# No custom domains w/ SSL, deployment slots, or autoscale on F1.
# SKU ladder: F1(free) → B1(~$13/mo) → S1(~$56/mo) → P1v3(~$115/mo) → P0v3(~$38/mo)

resource "azurerm_service_plan" "asp" {
  name                = "${local.name_prefix}-asp"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  os_type             = var.app_service_os
  sku_name            = var.app_service_sku
  tags                = local.common_tags
}

resource "azurerm_linux_web_app" "webapp" {
  count               = var.app_service_os == "Linux" ? 1 : 0
  name                = "${local.name_prefix}-webapp"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = local.always_on  # false on F1 (not supported); true on B1+
  }

  tags = local.common_tags
}

resource "azurerm_windows_web_app" "webapp_win" {
  count               = var.app_service_os == "Windows" ? 1 : 0
  name                = "${local.name_prefix}-webapp"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = local.always_on
  }

  tags = local.common_tags
}

# ── Static Web App — Free tier ($0) ──────────────────────────────────────────
# Truly free: global CDN, custom domains w/ free SSL, GitHub/Azure DevOps CI/CD.
# Standard tier ($9/mo) adds private endpoints and SLA.

resource "azurerm_static_web_app" "swa" {
  name                = "${local.name_prefix}-swa"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = local.common_tags
}

# ── Azure Container Registry (ACR) ───────────────────────────────────────────
# No free tier exists. Basic ~$5/mo, Standard ~$20/mo, Premium ~$50/mo.
# Basic is sufficient for learning: 10 GB storage, webhooks, geo-replication N/A.

resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_resource_group.compute.location
  sku                 = var.acr_sku
  admin_enabled       = false  # Use RBAC (AcrPull/AcrPush roles) not admin credentials
  tags                = local.common_tags
}

# ── Container Apps (ACA) — Consumption, scales to zero ($0 when idle) ─────────
resource "azurerm_container_app_environment" "cae" {
  count                      = var.enable_aca ? 1 : 0
  name                       = "${local.name_prefix}-cae"
  location                   = azurerm_resource_group.compute.location
  resource_group_name        = azurerm_resource_group.compute.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  tags                       = local.common_tags
}

resource "azurerm_container_app" "aca" {
  count                        = var.enable_aca ? 1 : 0
  name                         = "${local.name_prefix}-ca"
  container_app_environment_id = azurerm_container_app_environment.cae[0].id
  resource_group_name          = azurerm_resource_group.compute.name
  revision_mode                = "Single"
  tags                         = local.common_tags

  template {
    min_replicas = 0  # Scale to zero = $0 when idle
    max_replicas = 3

    container {
      name   = "app"
      image  = var.aca_image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# ── Azure Batch Account — $0 to create ────────────────────────────────────────
# No pools defined here — compute nodes spin up when jobs are submitted.
# Charges apply only while pool nodes are allocated (pay-per-VM-second).

resource "azurerm_batch_account" "batch" {
  count               = var.enable_batch ? 1 : 0
  name                = local.batch_name
  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_resource_group.compute.location
  pool_allocation_mode = "BatchService"
  tags                = local.common_tags
}

# ── Virtual Machine (optional, disabled by default) ───────────────────────────
# B1s (~$7/mo running). OS disk (~$1.5/mo even when deallocated).
# Deallocate via portal/CLI to stop compute charges while keeping the disk.

resource "azurerm_public_ip" "vm_pip" {
  count               = var.enable_vm ? 1 : 0
  name                = "${local.name_prefix}-pip-vm"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  allocation_method   = "Dynamic"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "vm_nic" {
  count               = var.enable_vm ? 1 : 0
  name                = "${local.name_prefix}-nic-vm"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_snet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[0].id
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.enable_vm ? 1 : 0
  name                            = "${local.name_prefix}-vm"
  resource_group_name             = azurerm_resource_group.compute.name
  location                        = azurerm_resource_group.compute.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  disable_password_authentication = var.vm_ssh_public_key != ""
  admin_password                  = var.vm_ssh_public_key == "" ? var.vm_admin_password : null
  network_interface_ids           = [azurerm_network_interface.vm_nic[0].id]

  dynamic "admin_ssh_key" {
    for_each = var.vm_ssh_public_key != "" ? [1] : []
    content {
      username   = var.vm_admin_username
      public_key = var.vm_ssh_public_key
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

# ── Azure Container Instances (optional, disabled by default) ─────────────────
# Billed per vCPU-second and GB-memory-second while running.
# No "stopped" state — to pause costs, delete the container group and recreate.

resource "azurerm_container_group" "aci" {
  count               = var.enable_aci ? 1 : 0
  name                = "${local.name_prefix}-aci"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  ip_address_type     = "Public"
  dns_name_label      = "${local.name_prefix}-aci"
  os_type             = "Linux"
  tags                = local.common_tags

  container {
    name   = "app"
    image  = var.aci_image
    cpu    = var.aci_cpu
    memory = var.aci_memory

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

# ── AKS (optional, disabled by default) ──────────────────────────────────────
# Control plane: FREE (sku_tier = "Free"). Node VMs: pay per hour.
# Upgrade sku_tier to "Standard" ($0.10/vCPU-hour) for production SLA.

resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.enable_aks ? 1 : 0
  name                = "${local.name_prefix}-aks"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  dns_prefix          = "${local.name_prefix}-aks"
  sku_tier            = "Free"  # Free control plane

  default_node_pool {
    name           = "system"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_size
    vnet_subnet_id = azurerm_subnet.aks_snet[0].id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}
