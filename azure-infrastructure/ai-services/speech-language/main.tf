resource "azurerm_resource_group" "speech_language" {
  name     = "${local.name_prefix}-rg-speech-lang"
  location = var.location
  tags     = local.common_tags
}

# ── Azure AI Speech ───────────────────────────────────────────────────────────
# Capabilities: speech-to-text, text-to-speech, speaker recognition,
#               speech translation, custom neural voice.

resource "azurerm_cognitive_account" "speech" {
  name                  = "${local.name_prefix}-cog-speech"
  location              = azurerm_resource_group.speech_language.location
  resource_group_name   = azurerm_resource_group.speech_language.name
  kind                  = "SpeechServices"
  sku_name              = var.speech_sku
  custom_subdomain_name = "${local.name_prefix}-cog-speech"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Azure AI Language (Text Analytics) ───────────────────────────────────────
# Capabilities: NER, sentiment analysis, key phrase extraction, summarisation,
#               custom classification, conversational language understanding (CLU).

resource "azurerm_cognitive_account" "language" {
  name                  = "${local.name_prefix}-cog-lang"
  location              = azurerm_resource_group.speech_language.location
  resource_group_name   = azurerm_resource_group.speech_language.name
  kind                  = "TextAnalytics"
  sku_name              = var.language_sku
  custom_subdomain_name = "${local.name_prefix}-cog-lang"

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ── Diagnostics ───────────────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "speech_diag" {
  name                       = "${local.name_prefix}-diag-speech"
  target_resource_id         = azurerm_cognitive_account.speech.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "language_diag" {
  name                       = "${local.name_prefix}-diag-lang"
  target_resource_id         = azurerm_cognitive_account.language.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
