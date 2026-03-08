provider "aws" {
  region = var.region
  # Credentials supplied by GitHub Actions OIDC via aws-actions/configure-aws-credentials
}
