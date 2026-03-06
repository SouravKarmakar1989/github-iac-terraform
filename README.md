# github-iac-terraform (Azure minimal cost smoke test)

Minimal Azure Terraform stack to validate:
- GitHub Actions OIDC login to Azure (no secrets)
- Remote state backend in Azure Storage
- Deployment executed on an ephemeral self-hosted runner

## Deploys (minimal cost)
- Resource Group (default `rg-lab-dev`)
- Storage Account (Standard/LRS)
- Private container `smoketest`

## Prerequisites
1. Create resource groups:
   - `rg-tfstate` (state)
   - `rg-lab-dev` (lab resources)
2. Create backend storage (one time):
   - Storage account: `sttfstate<unique>`
   - Container: `tfstate`
3. Create Entra App Registration for this repo with Federated Credential (main branch) and assign **Contributor** role on `rg-lab-dev`
4. Set repo variables:
   - `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`

## Run
1) Bring runner online from `github-runner-platform` repo (create workflow)
2) Actions → `azure-minimal-apply`
3) Verify in Azure Portal under `rg-lab-dev`

## Destroy
Actions → `azure-minimal-destroy`
