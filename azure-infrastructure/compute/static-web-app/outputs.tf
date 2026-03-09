output "static_web_app_id" {
  value = azurerm_static_web_app.swa.id
}

output "default_host_name" {
  value = azurerm_static_web_app.swa.default_host_name
}

output "api_key" {
  description = "Deployment token — use as AZURE_STATIC_WEB_APPS_API_TOKEN in GitHub Actions"
  value       = azurerm_static_web_app.swa.api_key
  sensitive   = true
}
