provider "azurerm" {
  features {}
  use_oidc                       = true
  resource_provider_registrations = "none"
}
