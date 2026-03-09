# Makefile — Developer workflow shortcuts
# ─────────────────────────────────────────────────────────────────────────────
# Usage:
#   make help              — list all targets
#   make install           — one-time local setup
#   make scan              — run all local security scans
#   make fmt               — format all Terraform files
#   make validate          — validate all Terraform modules
#   make plan MOD=security/key-vault ENV=dev
# ─────────────────────────────────────────────────────────────────────────────

.DEFAULT_GOAL := help
SHELL := /bin/bash

# Override on the command line: make plan MOD=security/key-vault ENV=staging
MOD  ?= azure-minimal
ENV  ?= dev
CLOUD ?= azure

AZURE_DIR := azure-infrastructure
AWS_DIR   := aws-infrastructure

# ── Colour helpers ────────────────────────────────────────────────────────────
BOLD  := \033[1m
RESET := \033[0m
GREEN := \033[32m
CYAN  := \033[36m

.PHONY: help
help:
	@echo ""
	@echo "  $(BOLD)github-iac-terraform$(RESET) — available targets"
	@echo ""
	@echo "  $(CYAN)Setup$(RESET)"
	@echo "    make install          One-time local dev setup (pre-commit, tools)"
	@echo ""
	@echo "  $(CYAN)Code Quality$(RESET)"
	@echo "    make fmt              terraform fmt --recursive on all modules"
	@echo "    make validate         terraform validate on all root modules"
	@echo "    make lint             tflint on all Azure modules"
	@echo ""
	@echo "  $(CYAN)Security Scans$(RESET)"
	@echo "    make scan             Checkov + Gitleaks + Trivy (local)"
	@echo "    make secrets          Gitleaks full history scan"
	@echo "    make iac-scan         Checkov on azure-infrastructure/"
	@echo "    make policy-test      OPA/Conftest tag policy unit tests"
	@echo ""
	@echo "  $(CYAN)Terraform$(RESET)"
	@echo "    make plan    MOD=<path> ENV=<env>   terraform plan"
	@echo "    make apply   MOD=<path> ENV=<env>   terraform apply (confirm prompt)"
	@echo "    make destroy MOD=<path> ENV=<env>   terraform destroy (confirm prompt)"
	@echo ""
	@echo "  $(CYAN)Pre-commit$(RESET)"
	@echo "    make hooks            Run all pre-commit hooks against all files"
	@echo ""

# ── One-time setup ────────────────────────────────────────────────────────────
.PHONY: install
install:
	@echo "$(GREEN)→ Installing pre-commit$(RESET)"
	pip install pre-commit detect-secrets
	pre-commit install
	pre-commit install --hook-type commit-msg
	@echo "$(GREEN)→ Init detect-secrets baseline$(RESET)"
	@if [ ! -f .secrets.baseline ]; then \
		detect-secrets scan > .secrets.baseline; \
		echo "Created .secrets.baseline — commit this file."; \
	fi
	@echo "$(GREEN)✓ Done. All pre-commit hooks installed.$(RESET)"

# ── Terraform helpers ─────────────────────────────────────────────────────────
.PHONY: fmt
fmt:
	@echo "$(GREEN)→ Formatting all Terraform files$(RESET)"
	find . -name "*.tf" -not -path "*/.terraform/*" \
		-exec dirname {} \; | sort -u | xargs -I{} terraform -chdir={} fmt

.PHONY: validate
validate:
	@echo "$(GREEN)→ Validating all root modules$(RESET)"
	@FAILED=0; \
	for dir in $$(find . -name "versions.tf" -not -path "*/.terraform/*" -exec dirname {} \; | sort -u); do \
		echo "  → $$dir"; \
		terraform -chdir="$$dir" init -backend=false -input=false -no-color > /dev/null 2>&1; \
		terraform -chdir="$$dir" validate -no-color || FAILED=1; \
	done; \
	exit $$FAILED

.PHONY: lint
lint:
	@echo "$(GREEN)→ Running tflint$(RESET)"
	@for dir in $$(find $(AZURE_DIR) -name "versions.tf" -not -path "*/.terraform/*" -exec dirname {} \; | sort -u); do \
		echo "  → $$dir"; \
		tflint --chdir="$$dir" --no-color || true; \
	done

.PHONY: plan
plan:
	@echo "$(GREEN)→ Plan: $(AZURE_DIR)/$(MOD) [$(ENV)]$(RESET)"
	terraform -chdir="$(AZURE_DIR)/$(MOD)" init -backend-config=env/$(ENV)/backend.hcl
	terraform -chdir="$(AZURE_DIR)/$(MOD)" plan -var-file=env/$(ENV)/terraform.tfvars

.PHONY: apply
apply:
	@echo "$(GREEN)→ Apply: $(AZURE_DIR)/$(MOD) [$(ENV)]$(RESET)"
	terraform -chdir="$(AZURE_DIR)/$(MOD)" init -backend-config=env/$(ENV)/backend.hcl
	terraform -chdir="$(AZURE_DIR)/$(MOD)" apply -var-file=env/$(ENV)/terraform.tfvars

.PHONY: destroy
destroy:
	@echo "$(BOLD)⚠ Destroy: $(AZURE_DIR)/$(MOD) [$(ENV)] — press Ctrl+C to cancel$(RESET)"
	terraform -chdir="$(AZURE_DIR)/$(MOD)" init -backend-config=env/$(ENV)/backend.hcl
	terraform -chdir="$(AZURE_DIR)/$(MOD)" destroy -var-file=env/$(ENV)/terraform.tfvars

# ── Security scans ────────────────────────────────────────────────────────────
.PHONY: iac-scan
iac-scan:
	@echo "$(GREEN)→ Checkov IaC scan$(RESET)"
	checkov -d $(AZURE_DIR) --config-file .checkov.yaml

.PHONY: secrets
secrets:
	@echo "$(GREEN)→ Gitleaks — full history scan$(RESET)"
	gitleaks detect --source . --verbose

.PHONY: scan
scan: iac-scan secrets
	@echo "$(GREEN)→ Trivy filesystem scan$(RESET)"
	trivy fs . --severity HIGH,CRITICAL --exit-code 1
	@echo "$(GREEN)✓ All scans passed$(RESET)"

.PHONY: policy-test
policy-test:
	@echo "$(GREEN)→ OPA/Conftest tag policy tests$(RESET)"
	conftest verify --policy policy/tags/

# ── Pre-commit ────────────────────────────────────────────────────────────────
.PHONY: hooks
hooks:
	pre-commit run --all-files
