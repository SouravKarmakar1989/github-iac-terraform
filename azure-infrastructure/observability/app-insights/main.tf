# ── Azure Application Insights ─────────────────────────────────────────────────
# Workspace-based Application Insights connected to the shared Log Analytics
# workspace. All applications (Container Apps, Functions, App Service, etc.)
# connect using the connection_string output.

resource "azurerm_application_insights" "appi" {
  name                = "${local.name_prefix}-appi"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.log_analytics_workspace_id
  application_type    = var.application_type
  tags                = local.common_tags
}
