output "webapp_hostname"       { value = try(azurerm_linux_web_app.webapp[0].default_hostname, azurerm_windows_web_app.webapp_win[0].default_hostname, null) }
output "static_webapp_url"    { value = azurerm_static_web_app.swa.default_host_name }
output "acr_login_server"     { value = azurerm_container_registry.acr.login_server }
output "aca_fqdn"             { value = try(azurerm_container_app.aca[0].ingress[0].fqdn, null) }
output "batch_endpoint"       { value = try(azurerm_batch_account.batch[0].account_endpoint, null) }
output "vm_public_ip"         { value = try(azurerm_public_ip.vm_pip[0].ip_address, null) }
output "aci_fqdn"             { value = try(azurerm_container_group.aci[0].fqdn, null) }
output "aks_kube_config"      { value = try(azurerm_kubernetes_cluster.aks[0].kube_config_raw, null); sensitive = true }
output "aks_host"             { value = try(azurerm_kubernetes_cluster.aks[0].kube_config[0].host, null); sensitive = true }
