# github-iac-terraform

> Azure minimal-cost smoke test — validates the full GitHub Actions → OIDC → Terraform → Azure deployment pipeline with zero long-lived secrets.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│  GitHub Repository  (SouravKarmakar1989/github-iac-terraform)           │
│                                                                         │
│  ┌──────────────────────┐    ┌───────────────────────────────────────┐  │
│  │  Workflow Trigger    │    │  Repository Variables (non-secret)    │  │
│  │  (workflow_dispatch) │    │  AZURE_CLIENT_ID                      │  │
│  └──────────┬───────────┘    │  AZURE_TENANT_ID                      │  │
│             │                │  AZURE_SUBSCRIPTION_ID                │  │
│             ▼                └───────────────────────────────────────┘  │
│  ┌──────────────────────┐                                               │
│  │  GitHub Actions      │  permissions:                                 │
│  │  Runner              │    id-token: write  ← required for OIDC       │
│  │  (ubuntu-latest)     │    contents: read                             │
│  └──────────┬───────────┘                                               │
└─────────────┼───────────────────────────────────────────────────────────┘
              │  OIDC JWT token exchange (no client secret)
              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  Microsoft Entra ID (Azure AD)                                          │
│                                                                         │
│  App Registration                                                       │
│  ├── Federated Credential  →  repo:*/github-iac-terraform:ref:main      │
│  └── Service Principal (Object ID: 3f62a42b-...)                        │
│       ├── Contributor  →  /subscriptions/<id>  (create RG + resources)  │
│       ├── Reader  →  storageAccounts/satfstate2301  (backend read)      │
│       └── Storage Blob Data Contributor  →  satfstate2301  (state r/w)  │
└─────────────────────────────────────────────────────────────────────────┘
              │  Authenticated ARM + Storage calls
              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  Azure Subscription: d43789e3-...                                       │
│                                                                         │
│  ┌──────────────────────────────┐  ┌──────────────────────────────────┐ │
│  │  rg-tfstate                  │  │  rg-lab-dev  (managed by TF)     │ │
│  │  (pre-existing, not in TF)   │  │                                  │ │
│  │                              │  │  azurerm_resource_group.lab      │ │
│  │  Storage Account: satfstate2301  │  azurerm_storage_account.sa     │ │
│  │  ├── Container: tfstate      │  │  ├── Standard LRS                │ │
│  │  │   └── azure-minimal/      │  │  ├── TLS 1.2 minimum             │ │
│  │  │       dev.tfstate  ◄──────┼──┤  └── no public blob access       │ │
│  │  │   (Terraform remote state)│  │                                  │ │
│  │  └── use_azuread_auth = true │  │  azurerm_storage_container.c     │ │
│  │      (no listKeys needed)    │  │  └── "smoketest" (private)       │ │
│  └──────────────────────────────┘  └──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── azure-minimal-apply.yml     # Terraform init → plan → apply
│       └── azure-minimal-destroy.yml  # Terraform init → destroy
├── infrastructure/
│   └── azure-minimal/
│       ├── main.tf                     # Resources: RG, Storage Account, Container
│       ├── variables.tf                # Input variables
│       ├── outputs.tf                  # Outputs: rg name, sa name, container name
│       ├── providers.tf                # azurerm provider (OIDC, skip registration)
│       ├── versions.tf                 # azurerm ~> 3.110, terraform >= 1.6.0
│       └── env/
│           └── dev/
│               ├── backend.hcl         # Remote state config (Azure AD auth)
│               └── terraform.tfvars    # Dev environment variable values
└── README.md
```

---

## Infrastructure Components

### Terraform-Managed Resources (`rg-lab-dev`)

| Resource | Type | Config |
|---|---|---|
| `azurerm_resource_group.lab` | Resource Group | Name from `var.lab_rg_name`, location from `var.location` |
| `azurerm_storage_account.sa` | Storage Account | Standard LRS, TLS 1.2+, no public blob access, name = `{prefix}{env}{random6}` |
| `azurerm_storage_container.c` | Blob Container | Name: `smoketest`, access: private |
| `random_string.suffix` | Random suffix | 6-char lowercase alphanumeric, ensures unique SA name |

### Pre-Existing Infrastructure (`rg-tfstate`, not managed by Terraform)

| Resource | Purpose |
|---|---|
| Storage Account `satfstate2301` | Holds Terraform remote state |
| Blob Container `tfstate` | State files per stack/env (e.g. `azure-minimal/dev.tfstate`) |

---

## Authentication — OIDC (No Secrets)

GitHub Actions uses **OpenID Connect (OIDC)** to exchange a short-lived JWT for an Azure access token. This eliminates the need for client secrets or certificates stored in GitHub.

**Flow:**
1. Job requests an OIDC token from GitHub (`id-token: write` permission)
2. `azure/login@v2` exchanges the token with Entra ID
3. The Federated Credential on the App Registration validates the token's `sub` claim matches the repo + branch
4. Azure returns a short-lived access token scoped to the service principal
5. Terraform uses `use_oidc = true` in the provider to pick up the token automatically

**Required RBAC assignments on the Service Principal:**

| Role | Scope | Purpose |
|---|---|---|
| `Contributor` | Subscription | Create/manage resource groups and all lab resources |
| `Reader` | `satfstate2301` storage account | Read storage account metadata for backend init |
| `Storage Blob Data Contributor` | `satfstate2301` storage account | Read/write Terraform state blobs |

---

## Terraform Backend

File: [infrastructure/azure-minimal/env/dev/backend.hcl](infrastructure/azure-minimal/env/dev/backend.hcl)

```hcl
resource_group_name  = "rg-tfstate"
storage_account_name = "satfstate2301"
container_name       = "tfstate"
key                  = "azure-minimal/dev.tfstate"
use_azuread_auth     = true   # Uses OIDC token — no listKeys permission needed
```

`use_azuread_auth = true` instructs the azurerm backend to authenticate via Azure AD rather than storage account keys, which requires only `Storage Blob Data Contributor` instead of `Contributor` on the storage account.

---

## Provider Configuration

File: [infrastructure/azure-minimal/providers.tf](infrastructure/azure-minimal/providers.tf)

```hcl
provider "azurerm" {
  features {}
  use_oidc                   = true   # Authenticate via OIDC token
  skip_provider_registration = true   # SP lacks subscription-level register/* permissions
}
```

`skip_provider_registration = true` prevents Terraform from attempting to register all Azure resource providers (requires elevated subscription permissions). All required providers must already be registered in the subscription.

---

## CI/CD Workflows

### `azure-minimal-apply` — Deploy

Trigger: `workflow_dispatch` (manual)  
Runner: `ubuntu-latest` (GitHub-hosted)

| Step | Action |
|---|---|
| Checkout | `actions/checkout@v4` |
| Azure Login | `azure/login@v2` via OIDC using repo variables |
| Setup Terraform | `hashicorp/setup-terraform@v3` |
| `terraform init` | Initialises remote backend with `backend.hcl` |
| `terraform plan` | Plans changes using `env/dev/terraform.tfvars` |
| `terraform apply` | Applies with `-auto-approve` |

### `azure-minimal-destroy` — Teardown

Trigger: `workflow_dispatch` (manual)  
Runner: `ubuntu-latest` (GitHub-hosted)

Same init step, then `terraform destroy -auto-approve`.

---

## Prerequisites

### 1. Azure — One-time setup

```bash
# Create state backend resource group and storage
az group create -n rg-tfstate -l centralus
az storage account create -n satfstate2301 -g rg-tfstate --sku Standard_LRS --min-tls-version TLS1_2
az storage container create -n tfstate --account-name satfstate2301

# Create app registration + federated credential (OIDC)
az ad app create --display-name github-iac-terraform
# → note the appId (client ID) and objectId

# Create a federated credential for the main branch
az ad app federated-credential create --id <appId> --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:SouravKarmakar1989/github-iac-terraform:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

# Assign roles (use service principal object ID, not app client ID)
SP_OID=$(az ad sp show --id <appId> --query id -o tsv)

az role assignment create --assignee $SP_OID --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"

az role assignment create --assignee $SP_OID --role "Reader" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rg-tfstate/providers/Microsoft.Storage/storageAccounts/satfstate2301"

az role assignment create --assignee $SP_OID --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rg-tfstate/providers/Microsoft.Storage/storageAccounts/satfstate2301"
```

### 2. GitHub — Repository Variables

Navigate to **Settings → Secrets and variables → Actions → Variables tab**:

| Variable | Value |
|---|---|
| `AZURE_CLIENT_ID` | App Registration client (application) ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

---

## Running

### Apply (deploy)
1. GitHub → **Actions** → `azure-minimal-apply` → **Run workflow**
2. Verify resources in Azure Portal under `rg-lab-dev`

### Destroy (teardown)
1. GitHub → **Actions** → `azure-minimal-destroy` → **Run workflow**

---

## Outputs

| Output | Description |
|---|---|
| `lab_rg` | Name of the deployed resource group |
| `storage_account` | Name of the deployed storage account |
| `container` | Name of the deployed blob container |

---

## Environment Variables (`env/dev/terraform.tfvars`)

| Variable | Value | Description |
|---|---|---|
| `location` | `centralus` | Azure region |
| `env` | `dev` | Environment tag |
| `prefix` | `sk` | Prefix for resource naming |
| `lab_rg_name` | `rg-lab-dev` | Target resource group name |

