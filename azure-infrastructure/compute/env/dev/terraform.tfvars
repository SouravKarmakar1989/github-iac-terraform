prefix           = "sk"
location         = "eastus"
env              = "dev"

# App Service: F1 = truly free (60 CPU min/day, shared infra, no custom domain SSL)
app_service_sku  = "F1"
app_service_os   = "Linux"

# ACR: Basic (~$5/mo) — cheapest available SKU
acr_sku          = "Basic"

# Always-on resources ($0 at rest)
enable_aca       = true
enable_batch     = true

# Off by default — enable and set vm_ssh_public_key or vm_admin_password when needed
enable_vm        = false
enable_aci       = false
enable_aks       = false

# Uncomment and set when enable_vm = true:
# vm_ssh_public_key = "ssh-rsa AAAA..."
# vm_admin_password = "Replace_Me_123!"
