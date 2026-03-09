resource "azurerm_resource_group" "genai_agentic" {
  name     = "${local.name_prefix}-rg-genai-agentic"
  location = var.location
  tags     = local.common_tags
}

# ── Azure OpenAI Service ───────────────────────────────────────────────────────
# Single OpenAI account serving both generative AI and agentic workloads.
# GPT-4o supports chat completion, function calling, structured outputs, and tool use.

resource "azurerm_cognitive_account" "openai" {
  name                  = "${local.name_prefix}-oai-genai"
  location              = azurerm_resource_group.genai_agentic.location
  resource_group_name   = azurerm_resource_group.genai_agentic.name
  kind                  = "OpenAI"
  sku_name              = var.openai_sku
  custom_subdomain_name = "${local.name_prefix}-oai-genai"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Model Deployments ──────────────────────────────────────────────────────────

# GPT-4o — chat completion, function calling, structured outputs, tool use
resource "azurerm_cognitive_deployment" "gpt" {
  name                 = "${local.name_prefix}-gpt4o"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.gpt_model
    version = var.gpt_model_version
  }

  scale {
    type     = "Standard"
    capacity = var.gpt_capacity
  }
}

# text-embedding-ada-002 — vector embeddings for RAG and semantic memory
resource "azurerm_cognitive_deployment" "embedding" {
  name                 = "${local.name_prefix}-embedding"
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

# ── Storage — agent state, tool outputs, and document source data ─────────────

resource "azurerm_storage_account" "genai" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.genai_agentic.name
  location                        = azurerm_resource_group.genai_agentic.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "agent_state" {
  name                  = "agent-state"
  storage_account_name  = azurerm_storage_account.genai.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.genai.name
  container_access_type = "private"
}

# ── Container Apps — agentic runtime (Semantic Kernel / AutoGen / LangChain) ──
# Scales to zero when idle (min_replicas = 0)

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.name_prefix}-law-genai"
  location            = azurerm_resource_group.genai_agentic.location
  resource_group_name = azurerm_resource_group.genai_agentic.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_container_app_environment" "env" {
  name                       = "${local.name_prefix}-cae-genai"
  location                   = azurerm_resource_group.genai_agentic.location
  resource_group_name        = azurerm_resource_group.genai_agentic.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  tags                       = local.common_tags
}

resource "azurerm_container_app" "agent" {
  name                         = "${local.name_prefix}-ca-agent"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.genai_agentic.name
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

      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = azurerm_cognitive_account.openai.endpoint
      }
      env {
        name  = "AZURE_OPENAI_DEPLOYMENT"
        value = azurerm_cognitive_deployment.gpt.name
      }
      env {
        name  = "AZURE_OPENAI_EMBEDDING_DEPLOYMENT"
        value = azurerm_cognitive_deployment.embedding.name
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
