# Two-phase deployment. ENV selects the environment; PHASE selects the root.
#
#   make plan ENV=prd PHASE=foundation
#   make plan ENV=prd PHASE=services-aws
#
# foundation must be applied before any services-* root in the same environment.
ENV   ?= dev
PHASE ?= foundation
DEPLOY := deployments/$(ENV)/$(PHASE)
POLICY := compliance/policies

.PHONY: help init plan apply destroy fmt validate lint policy policy-plan security check

help:
	@echo "make init|plan|apply|destroy ENV=dev|stg|prd PHASE=foundation|services-aws|services-azure|services-gcp"
	@echo "make check    -- everything CI runs, locally"

init:
	cd $(DEPLOY) && terraform init -upgrade

plan:
	cd $(DEPLOY) && terraform plan -var-file=terraform.tfvars -out=tfplan

apply:
	cd $(DEPLOY) && terraform apply tfplan

destroy:
	cd $(DEPLOY) && terraform destroy -var-file=terraform.tfvars

fmt:
	terraform fmt -recursive

# Roots are discovered, not listed: a hand-maintained list drifts from the tree
# the first time someone adds a context, and then quietly stops checking it.
ROOTS = $(shell find . -name versions.tf -not -path './.git/*' -printf '%h\n' | sort)

validate:
	@set -e; for d in $(ROOTS); do \
		echo "==> $$d"; \
		( cd $$d && terraform init -backend=false -input=false >/dev/null && terraform validate ); \
	done

