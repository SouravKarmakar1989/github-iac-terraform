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
│       ├── terraform-apply.yml     # Terraform init → plan → apply  (all modules)
│       └── terraform-destroy.yml  # Terraform init → destroy        (all modules)
├── infrastructure/
│   ├── azure-minimal/                  # Smoke-test: RG + Storage Account + Container
│   │   ├── main.tf
│   │   ├── locals.tf                   # name_prefix, common_tags
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── versions.tf
│   │   └── env/
│   │       ├── dev/      { backend.hcl, terraform.tfvars }
│   │       ├── staging/  { backend.hcl, terraform.tfvars }
│   │       └── prod/     { backend.hcl, terraform.tfvars }
│   ├── afd/                            # Azure Front Door (CDN profile + endpoint + origin)
│   │   └── ...same layout...
│   ├── apim/                           # API Management
│   │   └── ...same layout...
│   ├── func-app/                       # Linux Function App (Consumption / Elastic Premium)
│   │   └── ...same layout...
│   └── vnet/                           # Virtual Network + subnets (for_each map)
│       └── ...same layout...
└── README.md
```

> Each module is **self-contained**: it owns its own providers, versions, locals, variables, outputs, and per-environment backend/tfvars. Modules share no code — copy-paste-adapt pattern.

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

## Module Catalogue

| Module | Azure Resources | State Key |
|---|---|---|
| `azure-minimal` | Resource Group, Storage Account, Blob Container | `azure-minimal/<env>.tfstate` |
| `afd` | Resource Group, Front Door Profile, Endpoint, Origin Group, Origin | `afd/<env>.tfstate` |
| `apim` | Resource Group, API Management (System-Assigned Identity) | `apim/<env>.tfstate` |
| `func-app` | Resource Group, Storage Account, App Service Plan, Linux Function App | `func-app/<env>.tfstate` |
| `vnet` | Resource Group, Virtual Network, Subnets (`for_each`) | `vnet/<env>.tfstate` |

### Per-Environment SKU Defaults

| Module | dev | staging | prod |
|---|---|---|---|
| `afd` | `Standard_AzureFrontDoor` | `Standard_AzureFrontDoor` | `Premium_AzureFrontDoor` |
| `apim` | `Developer_1` | `Basic_1` | `Standard_1` |
| `func-app` | `Y1` (Consumption) | `EP1` (Elastic Premium) | `EP2` (Elastic Premium) |
| `vnet` | `10.0.0.0/16` | `10.1.0.0/16` | `10.2.0.0/16` |

---

## Standard Module Layout

Every module under `infrastructure/` follows this identical layout:

```
<module>/
├── main.tf          # Resource definitions
├── locals.tf        # name_prefix = "${prefix}-${env}", common_tags map
├── variables.tf     # Input variables (location, env, prefix + module-specific)
├── outputs.tf       # Key resource IDs, names, endpoints
├── providers.tf     # azurerm provider with use_oidc + skip_provider_registration
├── versions.tf      # azurerm ~> 3.110, terraform >= 1.6.0, empty backend block
└── env/
    ├── dev/
    │   ├── backend.hcl       # key = "<module>/dev.tfstate"
    │   └── terraform.tfvars  # env = "dev", dev-tier SKUs
    ├── staging/
    │   ├── backend.hcl       # key = "<module>/staging.tfstate"
    │   └── terraform.tfvars  # env = "staging", mid-tier SKUs
    └── prod/
        ├── backend.hcl       # key = "<module>/prod.tfstate"
        └── terraform.tfvars  # env = "prod", prod-grade SKUs
```

### `locals.tf` pattern (same in every module)

```hcl
locals {
  name_prefix = "${var.prefix}-${var.env}"   # e.g. sk-dev

  common_tags = {
    env        = var.env
    module     = "<module-name>"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
```

Use `local.name_prefix` for all resource names and `merge(local.common_tags, { ... })` for tags.

---

## Adding a New Module

1. **Create the folder** `infrastructure/<new-module>/`
2. **Copy** `providers.tf` and `versions.tf` from any existing module — they are identical.
3. **Write** `variables.tf`, `locals.tf`, `main.tf`, `outputs.tf` following the standard layout above.
4. **Create** `env/dev/`, `env/staging/`, `env/prod/` with `backend.hcl` and `terraform.tfvars`:  
   - Set `key = "<new-module>/<env>.tfstate"` in each `backend.hcl`  
   - Set `env = "<env>"` and env-appropriate variable values in each `terraform.tfvars`
5. **Add the module name** to both workflow `options:` lists in `.github/workflows/`.
6. Push → run the `terraform-apply` workflow selecting the new module + `dev` environment.

---

## CI/CD Workflows

Both workflows accept three inputs at runtime:

| Input | Required | Options | Description |
|---|---|---|---|
| `module` | Yes | `azure-minimal`, `afd`, `apim`, `func-app`, `vnet` | Which infrastructure module to operate on |
| `environment` | Yes | `dev`, `staging`, `prod` | Target environment — selects `env/<env>/` files |
| `target_resource` | No | Any Terraform resource address | Appended as `-target=<value>`. Leave empty for full apply/destroy |

### `terraform-apply` — Deploy

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

### `terraform-destroy` — Teardown

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
1. GitHub → **Actions** → `terraform-apply` → **Run workflow**
2. Verify resources in Azure Portal under `rg-lab-dev`

### Destroy (teardown)
1. GitHub → **Actions** → `terraform-destroy` → **Run workflow**

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

