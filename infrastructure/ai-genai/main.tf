resource "azurerm_resource_group" "genai" {
  name     = "${local.name_prefix}-rg-genai"
  location = var.location
  tags     = local.common_tags
}

# ── Azure OpenAI Service ───────────────────────────────────────────────────────
# AI-102: "Implement generative AI solutions"
# Requires quota approval in target region: eastus / swedencentral recommended

resource "azurerm_cognitive_account" "openai" {
  name                  = "${local.name_prefix}-oai"
  location              = azurerm_resource_group.genai.location
  resource_group_name   = azurerm_resource_group.genai.name
  kind                  = "OpenAI"
  sku_name              = var.openai_sku
  custom_subdomain_name = "${local.name_prefix}-oai"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Model Deployments ──────────────────────────────────────────────────────────

# GPT-4o — chat completion, function calling, JSON mode
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

# text-embedding-ada-002 — vector embeddings for RAG / semantic search
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

# ── Azure AI Search — RAG / vector store ──────────────────────────────────────
# AI-102: Used with OpenAI "On Your Data" / Retrieval-Augmented Generation

resource "azurerm_search_service" "search" {
  name                = "${local.name_prefix}-srch"
  location            = azurerm_resource_group.genai.location
  resource_group_name = azurerm_resource_group.genai.name
  sku                 = var.search_sku

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Document Storage (source data for indexing) ───────────────────────────────

resource "azurerm_storage_account" "docs" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.genai.name
  location                        = azurerm_resource_group.genai.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.docs.name
  container_access_type = "private"
}
