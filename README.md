# github-iac-terraform

> Enterprise-grade Infrastructure-as-Code for Azure (and AWS) — Terraform modules governed by a full CI/CD pipeline with OIDC authentication, shift-left security scanning, OPA policy enforcement, and automated drift detection. Zero long-lived secrets.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Repository Structure](#repository-structure)
3. [Module Catalogue](#module-catalogue)
4. [Authentication — OIDC (No Secrets)](#authentication--oidc-no-secrets)
5. [Terraform Backend](#terraform-backend)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Security & Quality Gates](#security--quality-gates)
8. [Local Development Setup](#local-development-setup)
9. [Standard Module Layout](#standard-module-layout)
10. [End-to-End Testing Guide](#end-to-end-testing-guide)
11. [Adding a New Module](#adding-a-new-module)
12. [GitHub Environment Protection Rules](#github-environment-protection-rules)
13. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Developer Workstation                                                       │
│                                                                              │
│  git commit  ──►  pre-commit hooks (local gate)                             │
│                    ├── detect-secrets    (secret scan)                       │
│                    ├── gitleaks          (git history scan)                  │
│                    ├── terraform fmt     (formatting)                        │
│                    ├── terraform validate (syntax)                           │
│                    ├── tflint            (lint)                              │
│                    ├── checkov           (IaC security, soft-fail)           │
│                    └── actionlint        (workflow YAML syntax)              │
└──────────────────────────────────────────────────────────────────────────────┘
                │  git push / pull request
                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  GitHub Repository  (SouravKarmakar1989/github-iac-terraform)                │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  CI Pipeline  (ci.yml) — runs on every PR and push to main             ││
│  │                                                                         ││
│  │  secret-scan ──► tf-lint ──► iac-scan ──► sast ──► sca ──► ci-gate    ││
│  │  (Gitleaks)    (fmt+      (Checkov     (Semgrep) (Trivy)  (aggregate)  ││
│  │                validate+  SARIF→                                        ││
│  │                tflint)    Security tab)                                 ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  Deploy Pipeline  (azure-terraform-apply.yml) — workflow_dispatch      ││
│  │                                                                         ││
│  │  plan job ──► [env gate if prod] ──► apply job                         ││
│  │  (always runs)   (reviewer approval)  (tf apply -auto-approve)         ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │  Drift Detection  (tf-drift-detect.yml) — daily 06:00 UTC Mon–Fri     ││
│  │  terraform plan -detailed-exitcode  →  exit 2 = drift                  ││
│  │  notify job opens a GitHub Issue if any matrix module drifted          ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  Repository Variables (non-secret, public by design)                        │
│  AZURE_CLIENT_ID  │  AZURE_TENANT_ID  │  AZURE_SUBSCRIPTION_ID             │
└───────────────────────────────────────┬──────────────────────────────────────┘
                                        │  OIDC JWT token exchange
                                        ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  Microsoft Entra ID                                                          │
│                                                                              │
│  App Registration: github-iac-terraform                                      │
│  ├── Federated Credential → repo:*/github-iac-terraform:ref:refs/heads/main  │
│  └── Service Principal                                                       │
│       ├── Contributor           → /subscriptions/<id>                        │
│       ├── Reader                → satfstate2301 storage account              │
│       └── Storage Blob Data Contributor → satfstate2301 (state r/w)          │
└───────────────────────────────────────┬──────────────────────────────────────┘
                                        │  Short-lived access token
                                        ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  Azure Subscription                                                          │
│                                                                              │
│  rg-tfstate  (pre-existing, not managed by Terraform)                        │
│  └── satfstate2301  →  container: tfstate  →  <module>/<env>.tfstate         │
│                                                                              │
│  Per-module resource groups  (managed by Terraform)                          │
│  ├── observability/log-analytics  →  rg-observability-<env>                  │
│  ├── security/key-vault           →  rg-security-<env>                       │
│  ├── ai-foundry/genAI-agentic     →  rg-agentic-<env>                        │
│  ├── ai-services/*                →  rg-ai-<service>-<env>                   │
│  └── azure-minimal                →  rg-lab-<env>                            │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── ci.yml                    # PR gate — 6 security + quality jobs
│       ├── azure-terraform-apply.yml # Plan (always) + Apply (prod gate)
│       ├── azure-terraform-destroy.yml
│       ├── aws-terraform-apply.yml
│       ├── aws-terraform-destroy.yml
│       └── tf-drift-detect.yml       # Daily drift detection, opens GH Issues
│
├── azure-infrastructure/
│   ├── observability/
│   │   ├── log-analytics/            # Shared Log Analytics Workspace
│   │   └── app-insights/             # Application Insights (workspace-based)
│   ├── security/
│   │   └── key-vault/                # Key Vault (RBAC mode, purge-protected)
│   ├── ai-foundry/
│   │   └── genAI-agentic/            # OpenAI + Container Apps agentic runtime
│   ├── ai-services/
│   │   ├── vision/                   # Computer Vision
│   │   ├── speech-language/          # Speech + Text Analytics
│   │   ├── doc-intelligence/         # Form Recognizer
│   │   ├── content-understanding/    # Content Understanding
│   │   └── ai-search/                # Azure AI Search (semantic)
│   ├── azure-minimal/                # Smoke-test: RG + Storage + Container
│   ├── afd/                          # Azure Front Door (CDN profile)
│   ├── apim/                         # API Management
│   ├── compute/
│   │   ├── container/  { acr, aca, aci, aks, spring-apps }
│   │   ├── iaas/       { vm, vmss, batch }
│   │   ├── paas/       { app-service }
│   │   ├── serverless/ { func-app, durable-func }
│   │   └── static-web-app/
│   ├── data-analytics/
│   ├── data-factory/
│   ├── database/       { cosmos, sql, postgres, mysql, redis }
│   ├── databricks/
│   ├── integration/
│   ├── network/        { core, dns, firewall }
│   └── storage/        { adls, blob, files }
│
├── aws-infrastructure/
│   └── aws-minimal/                  # S3 bucket smoke-test
│
├── policy/
│   └── tags/
│       ├── mandatory_tags.rego       # OPA policy: env/managed_by/repo tags required
│       └── mandatory_tags_test.rego  # 3 OPA unit tests
│
├── .pre-commit-config.yaml           # Local security hooks (6 hook groups)
├── .checkov.yaml                     # Checkov HIGH+ gate, 4 documented skips
├── .tflint.hcl                       # tflint azurerm plugin v0.27.0
├── .gitleaks.toml                    # Gitleaks config (excludes .secrets.baseline)
├── .semgrepignore                    # Semgrep: exclude .terraform/, tfstate, locks
├── .secrets.baseline                 # detect-secrets SHA256 baseline (no real creds)
├── Makefile                          # Developer workflow shortcuts
└── README.md
```

> Each module is **self-contained** — it owns its own `providers.tf`, `versions.tf`, `locals.tf`, `variables.tf`, `main.tf`, `outputs.tf`, and `env/{dev,staging,prod}/{backend.hcl,terraform.tfvars}`. Modules share no code. Copy-paste-adapt is intentional.

---

## Module Catalogue

### Platform / Shared (deploy first)

| Module path | Key resources | State key |
|---|---|---|
| `observability/log-analytics` | Log Analytics Workspace | `observability/log-analytics/<env>.tfstate` |
| `observability/app-insights` | Application Insights (workspace-based) | `observability/app-insights/<env>.tfstate` |
| `security/key-vault` | Key Vault (RBAC mode, purge-protected) | `security/key-vault/<env>.tfstate` |

### AI Foundry

| Module path | Key resources | State key |
|---|---|---|
| `ai-foundry/genAI-agentic` | OpenAI account, GPT-4o + embedding deployments, Container Apps, Storage | `ai-foundry/genAI-agentic/<env>.tfstate` |

### AI Services

| Module path | Key resources | State key |
|---|---|---|
| `ai-services/vision` | Computer Vision Cognitive Services account | `ai-services/vision/<env>.tfstate` |
| `ai-services/speech-language` | Speech Services + Text Analytics accounts | `ai-services/speech-language/<env>.tfstate` |
| `ai-services/doc-intelligence` | Form Recognizer + 2 storage containers | `ai-services/doc-intelligence/<env>.tfstate` |
| `ai-services/content-understanding` | Content Understanding cognitive account | `ai-services/content-understanding/<env>.tfstate` |
| `ai-services/ai-search` | Azure AI Search (semantic, RBAC auth) | `ai-services/ai-search/<env>.tfstate` |

### Core Azure

| Module path | Key resources | State key |
|---|---|---|
| `azure-minimal` | Resource Group, Storage Account, Blob Container | `azure-minimal/<env>.tfstate` |
| `afd` | Front Door Profile, Endpoint, Origin Group, Origin | `afd/<env>.tfstate` |
| `apim` | API Management (System-Assigned identity) | `apim/<env>.tfstate` |
| `databricks` | Databricks Workspace | `databricks/<env>.tfstate` |
| `data-factory` | Data Factory + Managed Identity | `data-factory/<env>.tfstate` |
| `data-analytics` | Synapse Workspace | `data-analytics/<env>.tfstate` |
| `integration` | Logic App / Service Bus integration | `integration/<env>.tfstate` |

### Network

| Module path | Key resources | State key |
|---|---|---|
| `network/core` | VNet, subnets (for_each map) | `network/core/<env>.tfstate` |
| `network/dns` | Private DNS Zones | `network/dns/<env>.tfstate` |
| `network/firewall` | Azure Firewall + Policy | `network/firewall/<env>.tfstate` |

### Compute

| Module path | Key resources |
|---|---|
| `compute/container/acr` | Azure Container Registry |
| `compute/container/aca` | Azure Container Apps Environment |
| `compute/container/aci` | Container Instances |
| `compute/container/aks` | AKS Cluster |
| `compute/container/spring-apps` | Azure Spring Apps |
| `compute/paas/app-service` | App Service Plan + Linux Web App |
| `compute/serverless/func-app` | Function App (Consumption/EP) |
| `compute/serverless/durable-func` | Durable Function App |
| `compute/iaas/vm` | Linux VM |
| `compute/iaas/vmss` | VM Scale Set |
| `compute/iaas/batch` | Batch Account + Pool |
| `compute/logic-app/consumption` | Logic App (Consumption) |
| `compute/logic-app/standard` | Logic App (Standard) |
| `compute/static-web-app` | Azure Static Web App |

### Storage & Database

| Module path | Key resources |
|---|---|
| `storage/blob` | Storage Account + Blob Containers |
| `storage/adls` | Storage Account (HNS enabled) |
| `storage/files` | Azure Files Share |
| `database/cosmos` | Cosmos DB Account |
| `database/sql` | Azure SQL Server + Database |
| `database/postgres` | PostgreSQL Flexible Server |
| `database/mysql` | MySQL Flexible Server |
| `database/redis` | Azure Cache for Redis |

### Per-Environment SKU Defaults

| Module | dev | staging | prod |
|---|---|---|---|
| `afd` | `Standard_AzureFrontDoor` | `Standard_AzureFrontDoor` | `Premium_AzureFrontDoor` |
| `apim` | `Developer_1` | `Basic_1` | `Standard_1` |
| `compute/serverless/func-app` | `Y1` (Consumption) | `EP1` (Elastic Premium) | `EP2` |
| `ai-services/ai-search` | `free` | `basic` | `standard` |
| `security/key-vault` | `standard` | `standard` | `premium` |

---

## Authentication — OIDC (No Secrets)

GitHub Actions uses **OpenID Connect (OIDC)** to obtain a short-lived Azure access token. No client secrets, certificates, or credentials are stored anywhere in GitHub.

### How it works

```
1. GitHub Actions runner requests an OIDC JWT
   (requires  permissions: id-token: write  in the workflow)

2. azure/login@v2 sends the JWT to Microsoft Entra ID token endpoint

3. Entra ID validates:
   - issuer  = https://token.actions.githubusercontent.com
   - subject = repo:SouravKarmakar1989/github-iac-terraform:ref:refs/heads/main
   - audience = api://AzureADTokenExchange

4. Entra ID returns a short-lived access token (≤ 1 hour)

5. Terraform provider picks up the token via  use_oidc = true
   (no ARM_CLIENT_SECRET env variable needed)
```

### Required RBAC assignments on the Service Principal

| Role | Scope | Purpose |
|---|---|---|
| `Contributor` | Subscription | Create/manage resource groups and all resources |
| `Reader` | `satfstate2301` storage account | Read storage account metadata for backend init |
| `Storage Blob Data Contributor` | `satfstate2301` storage account | Read/write Terraform state blobs |

> `use_azuread_auth = true` in `backend.hcl` means Terraform reads/writes state with the OIDC token — it never calls `listKeys` and never needs the storage account key.

---

## Terraform Backend

Every module backend points to the same shared storage account with a unique state key.

`env/dev/backend.hcl` pattern:

```hcl
resource_group_name  = "rg-tfstate"
storage_account_name = "satfstate2301"
container_name       = "tfstate"
key                  = "<module-path>/dev.tfstate"
use_azuread_auth     = true
```

State files are isolated per module per environment:

```
tfstate container/
├── azure-minimal/dev.tfstate
├── azure-minimal/staging.tfstate
├── azure-minimal/prod.tfstate
├── security/key-vault/dev.tfstate
├── ai-foundry/genAI-agentic/dev.tfstate
└── ...
```

**State is never stored locally.** Running `terraform init` with `-backend=false` is safe for `validate` runs in CI. Running without `-backend=false` requires a valid OIDC session.

---

## CI/CD Pipeline

The pipeline is split across four workflows, each with a distinct role.

### `ci.yml` — Pull Request Gate

Triggers on every pull request to `main` and on every push to `main`. This workflow must pass before any merge.

```
secret-scan ──► tf-lint ──► iac-scan ──► sast ──► sca
     │               │           │          │        │
     ▼               ▼           ▼          ▼        ▼
ci-gate  ◄──────────────────────────────────────────────
  (single required status check in branch protection)
```

| Job | Tool | What it checks |
|---|---|---|
| `secret-scan` | Gitleaks v8 | Full git history for leaked credentials |
| `tf-lint` | terraform fmt + validate + tflint | Formatting, syntax, provider/type correctness |
| `iac-scan` | Checkov (SARIF → Security tab) | Misconfigurations: public storage, missing encryption, open NSGs |
| `sast` | Semgrep (SARIF → Security tab) | Secrets in code, insecure patterns |
| `sca` | Trivy | Known CVEs in provider version constraints |
| `ci-gate` | Python aggregator | Passes only when all 5 jobs pass |

Configure branch protection: **Settings → Branches → main → Require status checks → `CI Gate`**.

### `azure-terraform-apply.yml` — Deploy

Trigger: `workflow_dispatch`. Inputs: `module`, `environment`, `target_resource` (optional).

```
   plan job                       apply job
(always runs)                 (gated for prod)
      │                              │
  tf init                       tf init
  tf plan -out=tfplan           tf apply (uses -var-file only)
  upload artifact  ─────────►  (pauses for reviewer if env=prod)
```

- **Dev / Staging**: `apply` runs immediately after `plan` with no approval.
- **Prod**: `apply` pauses and sends a reviewer notification email. A required reviewer must approve from the GitHub Actions UI before Terraform applies.

### `azure-terraform-destroy.yml` — Teardown

Same structure as apply. The `destroy` job also sets `environment: ${{ inputs.environment }}`, so destroying `prod` also requires reviewer approval.

### `tf-drift-detect.yml` — Daily Drift Detection

Runs at 06:00 UTC, Monday–Friday (and on demand via `workflow_dispatch`). Runs `terraform plan -detailed-exitcode` against every module in a matrix.

- **Exit code 0**: no changes — infrastructure matches state.
- **Exit code 2**: changes detected — infrastructure has drifted.

If any matrix job returns exit code 2, the `notify` job opens a GitHub Issue labelled `drift` + `infrastructure` with a link to the failing run.

---

## Security & Quality Gates

### Local hooks (`.pre-commit-config.yaml`)

Runs automatically on every `git commit`. Install once per workstation — see [Local Development Setup](#local-development-setup).

| Hook group | Hook | Action |
|---|---|---|
| General hygiene | `trailing-whitespace`, `end-of-file-fixer`, `check-yaml`, `check-json`, `check-merge-conflict`, `detect-private-key`, `check-added-large-files` | Catch common mistakes instantly |
| Secret detection | `detect-secrets` v1.5.0 | High-entropy strings, API keys, tokens vs. baseline |
| Git history scan | `gitleaks` v8.18.4 | Full history secret scan, config via `.gitleaks.toml` |
| Terraform | `terraform_fmt`, `terraform_validate`, `terraform_tflint`, `terraform_checkov` (soft-fail) | Format, syntax, lint, IaC scan |
| Workflow lint | `actionlint` | Validates `.github/workflows/*.yml` syntax |

### Checkov (`.checkov.yaml`)

- **Gate level**: `HIGH` severity and above (fails the CI job).
- **SARIF upload**: results appear in the **Security → Code scanning** tab.
- **Documented skips** (4 rules, each with a justification comment in `.checkov.yaml`):
  - `CKV_AZURE_3` — HTTPS-only enforced via `min_tls_version = "TLS1_2"` in all modules.
  - `CKV_AZURE_110` — KV purge protection disabled in dev sandbox only; `var.purge_protection_enabled` defaults `true` (prod-safe).
  - `CKV_AZURE_226` — External ingress intentionally enabled on genAI-agentic Container App.
  - `CKV_TF_1` — Backend type check false-positives during `-backend=false` validate runs.

### tflint (`.tflint.hcl`)

- azurerm plugin v0.27.0.
- Enabled rules: `terraform_required_version`, `terraform_required_providers`, `terraform_comment_syntax`, `terraform_deprecated_interpolation`, `terraform_unused_declarations`.
- `terraform_naming_convention` disabled — naming is handled by `locals.name_prefix`.

### Gitleaks (`.gitleaks.toml`)

Extends the default ruleset. Path-based allowlist excludes `.secrets.baseline` (which contains only SHA256 hashes of previously identified secrets, not real credentials).

### detect-secrets (`.secrets.baseline`)

Baseline generated with `detect-secrets scan`. Contains 12 findings in database `terraform.tfvars` files — all verified as non-real (DB connection string placeholders). Every new commit is checked against this baseline. To update after adding a known false positive:

```bash
detect-secrets scan > .secrets.baseline
git add .secrets.baseline
git commit -m "chore: update secrets baseline"
```

### OPA Tag Policy (`policy/tags/`)

`mandatory_tags.rego` enforces that every non-exempt resource has these tags:

| Tag key | Example value |
|---|---|
| `env` | `dev` / `staging` / `prod` |
| `managed_by` | `terraform` |
| `repo` | `github-iac-terraform` |

Run locally with Conftest:

```bash
conftest test azure-infrastructure/security/key-vault/main.tf \
  --policy policy/tags/ --parser=hcl2 --no-color
```

---

## Local Development Setup

### Prerequisites

| Tool | Version | Install |
|---|---|---|
| Terraform | >= 1.6.0 | [developer.hashicorp.com/terraform](https://developer.hashicorp.com/terraform/downloads) |
| Azure CLI | latest | `winget install Microsoft.AzureCLI` |
| Python | >= 3.10 | [python.org](https://www.python.org/downloads/) |
| pre-commit | >= 3.0 | `pip install pre-commit` |
| detect-secrets | 1.5.0 | `pip install detect-secrets` |
| tflint | latest | [github.com/terraform-linters/tflint](https://github.com/terraform-linters/tflint/releases) |
| Checkov | latest | `pip install checkov` |
| Gitleaks | >= 8.18 | [github.com/gitleaks/gitleaks](https://github.com/gitleaks/gitleaks/releases) |
| Conftest | latest | [conftest.dev](https://www.conftest.dev/install/) |
| Make | - | `winget install GnuWin32.Make` (Windows) |

### One-time workstation setup

```bash
# 1. Clone the repository
git clone https://github.com/SouravKarmakar1989/github-iac-terraform.git
cd github-iac-terraform

# 2. Install pre-commit hooks (runs automatically on every git commit)
pip install pre-commit detect-secrets
pre-commit install

# 3. Verify hooks are installed
cat .git/hooks/pre-commit   # should contain "pre-commit" framework code

# 4. Test all hooks against every file (first run downloads hook tools)
pre-commit run --all-files

# 5. Or use the Makefile shortcut
make install
```

### Azure CLI login for local Terraform runs

```bash
az login
az account set --subscription <AZURE_SUBSCRIPTION_ID>

# Terraform will pick up the Azure CLI token automatically when:
#   use_oidc = true  +  az login is active
# No environment variables needed locally.
```

### Running Terraform locally

```bash
# Plan a module
make plan MOD=security/key-vault ENV=dev

# Apply
make apply MOD=azure-minimal ENV=dev

# Destroy
make destroy MOD=azure-minimal ENV=dev

# Format all .tf files
make fmt

# Validate all root modules
make validate

# Run all security scans locally
make scan

# Run OPA policy tests
make policy-test
```

---

## Standard Module Layout

Every module follows an identical layout. Copy from any existing module and adapt.

```
<module>/
├── main.tf          # Resource definitions only — no locals, no providers
├── locals.tf        # name_prefix = "${var.prefix}-${var.env}", common_tags
├── variables.tf     # Input variables with types, descriptions, defaults
├── outputs.tf       # Key resource IDs, names, endpoints exported as outputs
├── providers.tf     # azurerm { use_oidc = true, skip_provider_registration = true }
├── versions.tf      # required_version, required_providers, empty backend {}
└── env/
    ├── dev/
    │   ├── backend.hcl       # key = "<module>/dev.tfstate", use_azuread_auth = true
    │   └── terraform.tfvars  # env = "dev", dev-tier SKUs and sizes
    ├── staging/
    │   ├── backend.hcl
    │   └── terraform.tfvars
    └── prod/
        ├── backend.hcl
        └── terraform.tfvars
```

### `versions.tf` pattern

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }

  backend "azurerm" {}   # populated at runtime via -backend-config=env/<env>/backend.hcl
}
```

### `providers.tf` pattern

```hcl
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  use_oidc                   = true
  skip_provider_registration = true
}
```

### `locals.tf` pattern

```hcl
locals {
  name_prefix = "${var.prefix}-${var.env}"   # e.g. "sk-dev"

  common_tags = {
    env        = var.env
    module     = "<module-name>"
    managed_by = "terraform"
    repo       = "github-iac-terraform"
  }
}
```

Use `local.name_prefix` for all resource names. Use `merge(local.common_tags, { extra = "tag" })` for resource tags.

---

## End-to-End Testing Guide

This section walks through a complete smoke-test from a fresh clone to a verified Azure deployment and back.

### Phase 1 — Pre-flight checks (local)

```bash
# Verify all tools are installed and hooks pass
make install          # installs pre-commit hooks, creates baseline if missing
make fmt              # formats all .tf files (must produce no diff)
make validate         # validates all root modules (must exit 0)
make scan             # Checkov + Gitleaks + Trivy (must pass)
make policy-test      # OPA tag policy unit tests (must pass)
```

Expected output:
- `make fmt` — no output (or all modules formatted).
- `make validate` — `Success! The configuration is valid.` for each module.
- `make scan` — all tools exit 0.
- `make policy-test` — `2 tests, 0 failures`.

### Phase 2 — Trigger the CI pipeline

1. Create a feature branch:
   ```bash
   git checkout -b test/smoke-$(date +%Y%m%d)
   echo "# test" >> README.md
   git add README.md
   git commit -m "test: smoke test commit"
   git push origin HEAD
   ```

2. Open a Pull Request on GitHub.

3. The `ci.yml` workflow triggers automatically. Watch the **Actions** tab.

4. Verify all 6 jobs turn green:
   - `Secret Scan (Gitleaks)` — ✅
   - `Terraform Lint & Validate` — ✅
   - `IaC Scan (Checkov)` — ✅ (SARIF results visible under **Security → Code scanning**)
   - `SAST (Semgrep)` — ✅
   - `SCA — Dependency Scan (Trivy)` — ✅
   - `CI Gate` — ✅

5. Merge the PR.

### Phase 3 — Deploy a module (dev)

Use `azure-minimal` as the smoke-test module — it creates a Resource Group, Storage Account, and Blob Container.

1. Go to **Actions → azure-terraform-apply → Run workflow**.
2. Set inputs:
   - `module` = `azure-minimal`
   - `environment` = `dev`
   - `target_resource` = *(leave empty)*
3. Click **Run workflow**.
4. Watch the workflow:
   - **Plan job** — runs `terraform init` + `terraform plan`. Inspect the plan output to confirm expected resources.
   - **Apply job** — runs immediately (no approval needed for dev). Confirm `Apply complete!` in the logs.

5. Verify in Azure Portal:
   - Resource group `rg-lab-dev` exists.
   - Storage account with prefix `sk` + `dev` + 6-char suffix exists.
   - Blob container `smoketest` exists inside the storage account.

6. Verify Terraform state:
   - In Azure Portal → Storage account `satfstate2301` → Container `tfstate` → blob `azure-minimal/dev.tfstate` exists and is non-empty.

### Phase 4 — Prod deployment with approval gate

1. Go to **Actions → azure-terraform-apply → Run workflow**.
2. Set inputs: `module` = `azure-minimal`, `environment` = `prod`.
3. The **Plan job** runs immediately and uploads a plan artifact.
4. The **Apply job** pauses with status **Waiting for review**.
5. A required reviewer receives an email notification.
6. The reviewer navigates to the workflow run, reviews the plan output (visible as an uploaded artifact), and clicks **Approve and deploy** or **Reject**.
7. On approval, `terraform apply` runs and completes.

### Phase 5 — Verify drift detection

1. Go to Azure Portal → resource group `rg-lab-dev` → add a manual tag `manual-change: true` to the storage account (simulates out-of-band change).

2. Go to **Actions → tf-drift-detect → Run workflow** (manual trigger).
   - Set `environment` = `dev`.

3. The `azure-minimal` matrix job detects drift (exit code 2 in `terraform plan -detailed-exitcode`).

4. The `notify` job creates a GitHub Issue titled `[Drift Detected] Terraform state mismatch — <date>` with a link to the run.

5. Remediate: re-run **azure-terraform-apply** (`azure-minimal`, `dev`) — the manual tag is removed and state reconciles.

### Phase 6 — Teardown

```bash
# Via GitHub Actions
# Actions → azure-terraform-destroy → Run workflow
# module = azure-minimal, environment = dev
```

Confirm in Azure Portal that `rg-lab-dev` and its resources no longer exist.

### Validation Checklist

| Test | Expected result |
|---|---|
| `make validate` locally | All modules: `Success! The configuration is valid.` |
| `make scan` locally | All tools exit 0 |
| PR opened | `CI Gate` ✅ in ~5 min |
| SARIF results appear | **Security → Code scanning** shows Checkov + Semgrep findings |
| `azure-minimal` dev apply | `rg-lab-dev` + storage account visible in Azure Portal |
| State blob present | `satfstate2301/tfstate/azure-minimal/dev.tfstate` non-empty |
| Prod apply pauses | Workflow status: `Waiting` until reviewer approves |
| Drift detected | GitHub Issue created with `drift` label |
| Destroy completes | `rg-lab-dev` removed from Azure Portal |

---

## Adding a New Module

1. **Create the folder** under the appropriate domain:
   ```bash
   mkdir -p azure-infrastructure/<domain>/<module-name>/env/{dev,staging,prod}
   ```

2. **Copy boilerplate** from an existing module at the same domain level:
   ```bash
   cp azure-infrastructure/azure-minimal/providers.tf  azure-infrastructure/<domain>/<module-name>/
   cp azure-infrastructure/azure-minimal/versions.tf   azure-infrastructure/<domain>/<module-name>/
   cp azure-infrastructure/azure-minimal/locals.tf     azure-infrastructure/<domain>/<module-name>/
   ```

3. **Author** `main.tf`, `variables.tf`, `outputs.tf` for your resources.

4. **Create env files** for each environment:

   `env/dev/backend.hcl`:
   ```hcl
   resource_group_name  = "rg-tfstate"
   storage_account_name = "satfstate2301"
   container_name       = "tfstate"
   key                  = "<domain>/<module-name>/dev.tfstate"
   use_azuread_auth     = true
   ```

   `env/dev/terraform.tfvars`:
   ```hcl
   location = "centralus"
   env      = "dev"
   prefix   = "sk"
   ```

5. **Update workflow module lists** — add the new module path to the `options:` list in both `.github/workflows/azure-terraform-apply.yml` and `.github/workflows/azure-terraform-destroy.yml`.

6. **Update drift detection** — add the new module to the `matrix.module` list in `.github/workflows/tf-drift-detect.yml`.

7. **Tag compliance** — ensure `locals.common_tags` includes `env`, `managed_by`, and `repo`. The OPA policy will fail CI otherwise.

8. **Test locally** before pushing:
   ```bash
   make plan MOD=<domain>/<module-name> ENV=dev
   ```

9. Push and open a PR — CI runs automatically.

---

## GitHub Environment Protection Rules

| GitHub Environment | Protection | Effect |
|---|---|---|
| `dev` | None | Apply/Destroy runs immediately after Plan |
| `staging` | None | Apply/Destroy runs immediately after Plan |
| `prod` | Required reviewers | Apply/Destroy job pauses for reviewer approval |

### Setting up the `prod` environment

1. Go to **Settings → Environments → prod**.
2. Under **Deployment protection rules**, enable **Required reviewers**.
3. Add yourself (and any other approvers).
4. Save.

From this point, every `azure-terraform-apply` or `azure-terraform-destroy` run targeting `prod` will pause at the apply/destroy job and send a reviewer notification email. Reviewer can inspect the plan artifact (uploaded by the `plan` job) before approving.

---

## Prerequisites — One-time Azure Setup

```bash
# 1. Create state backend infrastructure
az group create -n rg-tfstate -l centralus
az storage account create \
  -n satfstate2301 \
  -g rg-tfstate \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false
az storage container create -n tfstate --account-name satfstate2301

# 2. Create App Registration + Federated Credential
az ad app create --display-name github-iac-terraform
# Note the appId from the output

az ad app federated-credential create --id <appId> --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:SouravKarmakar1989/github-iac-terraform:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

# For PRs (CI pipeline also needs OIDC — optional but recommended)
az ad app federated-credential create --id <appId> --parameters '{
  "name": "github-pr",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:SouravKarmakar1989/github-iac-terraform:pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}'

# 3. Assign RBAC roles
SP_OID=$(az ad sp show --id <appId> --query id -o tsv)
SUB="/subscriptions/<subscription-id>"

az role assignment create --assignee $SP_OID --role "Contributor" --scope "$SUB"

az role assignment create --assignee $SP_OID --role "Reader" \
  --scope "$SUB/resourceGroups/rg-tfstate/providers/Microsoft.Storage/storageAccounts/satfstate2301"

az role assignment create --assignee $SP_OID --role "Storage Blob Data Contributor" \
  --scope "$SUB/resourceGroups/rg-tfstate/providers/Microsoft.Storage/storageAccounts/satfstate2301"
```

### GitHub Repository Variables

Navigate to **Settings → Secrets and variables → Actions → Variables tab** and add:

| Variable | Description | Example |
|---|---|---|
| `AZURE_CLIENT_ID` | App Registration (application) client ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure AD tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |

> These are **Variables** (not Secrets) — they are non-sensitive identifiers. The actual authentication is done via OIDC token exchange; no password or key is stored.

---

## Troubleshooting

### `terraform init` fails: `Error acquiring the state lock`

Someone else (or a previous failed run) holds the state lock. Check the blob lease:

```bash
az storage blob show \
  --account-name satfstate2301 \
  --container-name tfstate \
  --name "<module>/<env>.tfstate" \
  --query "properties.lease.status"
```

If `"locked"`, break the lease:

```bash
az storage blob lease break \
  --account-name satfstate2301 \
  --container-name tfstate \
  --blob-name "<module>/<env>.tfstate"
```

### `Error: MSI not available` / OIDC token errors

- Check that `id-token: write` permission is set in the workflow.
- Confirm the federated credential `subject` matches the exact branch/PR ref — e.g., `ref:refs/heads/main` (not `ref:main`).
- Ensure the GitHub Actions runner can reach `login.microsoftonline.com` (no egress block).

### `terraform validate` fails: `Error: Missing required argument`

The `backend {}` block in `versions.tf` is intentionally empty. Pass the backend config at init time:

```bash
terraform init -backend-config=env/dev/backend.hcl
# or for CI validate (no backend needed):
terraform init -backend=false
```

### `pre-commit` hook: `detect-secrets — Unable to read baseline`

The `.secrets.baseline` file has a UTF-8 BOM (PowerShell `Out-File` default). Regenerate using Python:

```bash
python -c "
import subprocess, sys, json
result = subprocess.run([sys.executable, '-m', 'detect_secrets', 'scan'],
                       capture_output=True, text=True)
with open('.secrets.baseline', 'w', encoding='utf-8', newline='') as f:
    json.dump(json.loads(result.stdout), f, indent=2)
print('Baseline written')
"
```

### Gitleaks flags `.secrets.baseline` itself

The `.gitleaks.toml` file excludes `.secrets.baseline` by path. If you see this error, confirm:

```bash
cat .gitleaks.toml
# should contain:
# [allowlist]
# paths = ['''.secrets.baseline''']
```

And that the `.pre-commit-config.yaml` gitleaks hook passes `args: ['--config=.gitleaks.toml']`.

### Checkov fails with `CKV_*` check not in skip list

Add the check ID with a justification comment to `.checkov.yaml` under `skip-check:`. Keep the list minimal and documented.

### Drift detected — how to remediate

1. Open the GitHub Issue created by `tf-drift-detect.yml` and click the workflow run link.
2. In the run, identify which matrix module drifted (the job that returned exit code 2).
3. Review the `plan_output.txt` artifact for that job to see the diff.
4. Run **azure-terraform-apply** for that module and environment to reconcile.
5. If the out-of-band change was intentional, update the Terraform code to match, then apply.
