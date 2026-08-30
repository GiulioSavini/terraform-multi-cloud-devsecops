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

ROOTS := platform/naming platform/tagging compliance/controls \
         domains/networking domains/access-control domains/cluster-platform \
         domains/traffic-ingress domains/policy-enforcement \
         domains/secrets-management domains/observability domains/service-mesh \
         applications/cloud-foundation applications/cluster-services \
         deployments/dev/foundation deployments/dev/services-aws \
         deployments/stg/foundation deployments/stg/services-aws deployments/stg/services-azure \
         deployments/prd/foundation deployments/prd/services-aws \
         deployments/prd/services-azure deployments/prd/services-gcp

validate:
	@set -e; for d in $(ROOTS); do \
		echo "==> $$d"; \
		( cd $$d && terraform init -backend=false -input=false >/dev/null && terraform validate ); \
	done

lint:
	tflint --recursive --minimum-failure-severity=warning

# Unit tests for the compliance policies themselves.
policy:
	conftest verify --policy $(POLICY)

# Evaluate a real plan against policy. Requires `make plan` first.
policy-plan:
	cd $(DEPLOY) && terraform show -json tfplan > tfplan.json
	conftest test --policy $(POLICY) $(DEPLOY)/tfplan.json

security:
	trivy config --exit-code 1 --severity CRITICAL,HIGH --ignorefile .trivyignore .

check: fmt validate policy
	terraform fmt -check -recursive
	./scripts/check-boundaries.sh
