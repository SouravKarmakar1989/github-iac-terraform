resource "azurerm_resource_group" "agent" {
  name     = "${local.name_prefix}-rg-agent"
  location = var.location
  tags     = local.common_tags
}

# ── Azure OpenAI — function calling model ─────────────────────────────────────
# AI-102: "Implement an agentic solution"
# GPT-4o supports parallel function calling + structured outputs (tool use)

resource "azurerm_cognitive_account" "openai" {
  name                  = "${local.name_prefix}-oai-agent"
  location              = azurerm_resource_group.agent.location
  resource_group_name   = azurerm_resource_group.agent.name
  kind                  = "OpenAI"
  sku_name              = var.openai_sku
  custom_subdomain_name = "${local.name_prefix}-oai-agent"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_cognitive_deployment" "agent_model" {
  name                 = "${local.name_prefix}-agent-model"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.agent_model
    version = var.agent_model_version
  }

  scale {
    type     = "Standard"
    capacity = var.agent_model_capacity
  }
}

# Embedding model — for semantic memory / vector retrieval
resource "azurerm_cognitive_deployment" "embedding" {
  name                 = "${local.name_prefix}-agent-embedding"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.embedding_model
    version = var.embedding_model_version
  }

  scale {
    type     = "Standard"
    capacity = var.embedding_capacity
  }
}

# ── Storage — agent state and tool outputs ─────────────────────────────────────

resource "azurerm_storage_account" "agent" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.agent.name
  location                        = azurerm_resource_group.agent.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "state" {
  name                  = "agent-state"
  storage_account_name  = azurerm_storage_account.agent.name
  container_access_type = "private"
}

# ── Container Apps — agent orchestration runtime ──────────────────────────────
# Runs the agent code (Semantic Kernel / AutoGen / LangChain etc.)
# Scales to zero when idle (min_replicas = 0)

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name_prefix}-law-agent"
  location            = azurerm_resource_group.agent.location
  resource_group_name = azurerm_resource_group.agent.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_container_app_environment" "env" {
  name                       = "${local.name_prefix}-cae-agent"
  location                   = azurerm_resource_group.agent.location
  resource_group_name        = azurerm_resource_group.agent.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  tags                       = local.common_tags
}

resource "azurerm_container_app" "agent" {
  name                         = "${local.name_prefix}-ca-agent"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.agent.name
  revision_mode                = "Single"
  tags                         = local.common_tags

  identity {
    type = "SystemAssigned"
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "agent"
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      # Injected at runtime — agent code reads these env vars
      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = azurerm_cognitive_account.openai.endpoint
      }
      env {
        name  = "AZURE_OPENAI_DEPLOYMENT"
        value = azurerm_cognitive_deployment.agent_model.name
      }
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
