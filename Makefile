.PHONY: help init plan apply destroy fmt validate lint sec clean

SHELL := /bin/bash
ENV ?= dev
TF_DIR := environments/$(ENV)
TERRAGRUNT := terragrunt
TF := terraform

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m

help: ## Show this help
	@echo "$(GREEN)Multi-Cloud DevSecOps Platform$(NC)"
	@echo "Usage: make <target> ENV=<dev|stg|prd>"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# ─── Terraform Targets ───────────────────────────────────────

init: ## Initialize Terraform for the given environment
	@echo "$(GREEN)Initializing $(ENV)...$(NC)"
	cd $(TF_DIR) && $(TF) init -upgrade

plan: ## Run Terraform plan for the given environment
	@echo "$(GREEN)Planning $(ENV)...$(NC)"
	cd $(TF_DIR) && $(TF) plan -out=tfplan -var-file=terraform.tfvars

apply: ## Apply Terraform plan for the given environment
	@echo "$(GREEN)Applying $(ENV)...$(NC)"
	cd $(TF_DIR) && $(TF) apply tfplan

destroy: ## Destroy infrastructure for the given environment
	@echo "$(RED)Destroying $(ENV)...$(NC)"
	cd $(TF_DIR) && $(TF) destroy -var-file=terraform.tfvars

# ─── Terragrunt Targets ──────────────────────────────────────

tg-init: ## Initialize with Terragrunt
	cd $(TF_DIR) && $(TERRAGRUNT) init

tg-plan: ## Plan with Terragrunt
	cd $(TF_DIR) && $(TERRAGRUNT) plan

tg-apply: ## Apply with Terragrunt
	cd $(TF_DIR) && $(TERRAGRUNT) apply

tg-destroy: ## Destroy with Terragrunt
	cd $(TF_DIR) && $(TERRAGRUNT) destroy

tg-plan-all: ## Plan all environments with Terragrunt
	$(TERRAGRUNT) run-all plan

tg-apply-all: ## Apply all environments with Terragrunt
	$(TERRAGRUNT) run-all apply

# ─── Quality Targets ─────────────────────────────────────────

fmt: ## Format all Terraform files
	@echo "$(GREEN)Formatting Terraform files...$(NC)"
	$(TF) fmt -recursive .

validate: ## Validate Terraform configuration
	@echo "$(GREEN)Validating $(ENV)...$(NC)"
	cd $(TF_DIR) && $(TF) validate

lint: ## Run TFLint
	@echo "$(GREEN)Linting...$(NC)"
	tflint --recursive --config .tflint.hcl

sec: ## Run security scans (tfsec + checkov)
	@echo "$(GREEN)Running tfsec...$(NC)"
	tfsec . --soft-fail
	@echo "$(GREEN)Running checkov...$(NC)"
	checkov -d $(TF_DIR) --quiet

# ─── Utility Targets ─────────────────────────────────────────

docs: ## Generate Terraform docs
	@echo "$(GREEN)Generating docs...$(NC)"
	find modules -name "main.tf" -execdir terraform-docs markdown table . -o README.md \;

cost: ## Estimate costs with Infracost
	@echo "$(GREEN)Running Infracost for $(ENV)...$(NC)"
	infracost breakdown --path $(TF_DIR)

clean: ## Clean Terraform cache and plans
	@echo "$(YELLOW)Cleaning...$(NC)"
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "tfplan" -delete 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	find . -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true

kubeconfig-aws: ## Get AWS EKS kubeconfig
	aws eks update-kubeconfig --name devsecops-$(ENV)-eks --region eu-west-1

kubeconfig-azure: ## Get Azure AKS kubeconfig
	az aks get-credentials --resource-group devsecops-$(ENV)-rg --name devsecops-$(ENV)-aks

kubeconfig-gcp: ## Get GCP GKE kubeconfig
	gcloud container clusters get-credentials devsecops-$(ENV)-gke --region europe-west1

docker-build: ## Build the workspace Docker image
	docker build -t devsecops-workspace:latest .

docker-run: ## Run the workspace container
	docker run -it --rm \
		-v $(PWD):/workspace \
		-v ~/.aws:/root/.aws:ro \
		-v ~/.azure:/root/.azure:ro \
		-v ~/.config/gcloud:/root/.config/gcloud:ro \
		devsecops-workspace:latest
