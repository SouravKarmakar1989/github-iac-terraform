provider "azurerm" {
  features {}
  use_oidc                   = true
  skip_provider_registration = true
}
