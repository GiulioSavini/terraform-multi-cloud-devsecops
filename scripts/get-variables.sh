#!/usr/bin/env bash
# =============================================================================
# get-variables.sh - DevSecOps Platform
# Auto-discovers cloud variables and generates terraform.tfvars
# Usage: ./scripts/get-variables.sh [dev|stg|prd]
# =============================================================================
set -euo pipefail

ENV=${1:-dev}
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "=============================================="
echo "  Auto-discovering variables for: $ENV"
echo "=============================================="

# --- AWS ---
echo -e "\n${CYAN}--- AWS ---${NC}"
if command -v aws &>/dev/null && aws sts get-caller-identity &>/dev/null; then
  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  AWS_REGION=$(aws configure get region 2>/dev/null || echo "eu-west-1")
  echo -e "${GREEN}Account:${NC} $AWS_ACCOUNT_ID | ${GREEN}Region:${NC} $AWS_REGION"
else
  echo -e "${YELLOW}AWS not authenticated${NC}"
  AWS_REGION="eu-west-1"
fi

# --- Azure ---
echo -e "\n${CYAN}--- Azure ---${NC}"
if command -v az &>/dev/null && az account show &>/dev/null 2>&1; then
  AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
  AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
  echo -e "${GREEN}Subscription:${NC} $AZURE_SUBSCRIPTION_ID | ${GREEN}Tenant:${NC} $AZURE_TENANT_ID"
else
  echo -e "${YELLOW}Azure not authenticated${NC}"
  AZURE_SUBSCRIPTION_ID="CHANGE_ME"
  AZURE_TENANT_ID="CHANGE_ME"
fi

# --- GCP ---
echo -e "\n${CYAN}--- GCP ---${NC}"
if command -v gcloud &>/dev/null; then
  GCP_PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "CHANGE_ME")
  GCP_REGION=$(gcloud config get-value compute/region 2>/dev/null || echo "europe-west1")
  echo -e "${GREEN}Project:${NC} $GCP_PROJECT_ID | ${GREEN}Region:${NC} $GCP_REGION"
else
  echo -e "${YELLOW}gcloud not found${NC}"
  GCP_PROJECT_ID="CHANGE_ME"
  GCP_REGION="europe-west1"
fi

# --- Kubernetes tools ---
echo -e "\n${CYAN}--- Kubernetes Tools ---${NC}"
for tool in kubectl helm; do
  if command -v $tool &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} $tool: $($tool version --client --short 2>/dev/null || $tool version --short 2>/dev/null || echo 'installed')"
  else
    echo -e "${YELLOW}[MISSING]${NC} $tool"
  fi
done

# --- Generate tfvars ---
TFVARS_FILE="environments/$ENV/terraform.tfvars"
echo -e "\n=============================================="
echo -e "  Generating ${GREEN}$TFVARS_FILE${NC}"
echo "=============================================="

# Set sizing based on environment
case $ENV in
  dev)
    EKS_INSTANCE="t3.medium"; EKS_NODES=1; EKS_MAX=3
    AKS_SIZE="Standard_B2s"; AKS_NODES=1; AKS_MAX=3
    GKE_TYPE="e2-medium"; GKE_NODES=1; GKE_MAX=3
    VAULT_REPLICAS=1
    ;;
  stg)
    EKS_INSTANCE="t3.large"; EKS_NODES=2; EKS_MAX=5
    AKS_SIZE="Standard_D2s_v5"; AKS_NODES=2; AKS_MAX=5
    GKE_TYPE="e2-standard-2"; GKE_NODES=2; GKE_MAX=5
    VAULT_REPLICAS=3
    ;;
  prd)
    EKS_INSTANCE="m5.xlarge"; EKS_NODES=3; EKS_MAX=10
    AKS_SIZE="Standard_D4s_v5"; AKS_NODES=3; AKS_MAX=10
    GKE_TYPE="e2-standard-4"; GKE_NODES=3; GKE_MAX=10
    VAULT_REPLICAS=5
    ;;
esac

cat > "$TFVARS_FILE" << EOF
# Auto-generated on $(date -Iseconds)
project     = "devsecops"
environment = "$ENV"

# AWS EKS
aws_region          = "$AWS_REGION"
eks_instance_type   = "$EKS_INSTANCE"
eks_desired_nodes   = $EKS_NODES
eks_max_nodes       = $EKS_MAX

# Azure AKS
azure_subscription_id = "$AZURE_SUBSCRIPTION_ID"
azure_tenant_id       = "$AZURE_TENANT_ID"
azure_location        = "westeurope"
aks_vm_size           = "$AKS_SIZE"
aks_min_nodes         = $AKS_NODES
aks_max_nodes         = $AKS_MAX

# GCP GKE
gcp_project_id    = "$GCP_PROJECT_ID"
gcp_region        = "$GCP_REGION"
gke_machine_type  = "$GKE_TYPE"
gke_min_nodes     = $GKE_NODES
gke_max_nodes     = $GKE_MAX

# Shared
vault_replicas     = $VAULT_REPLICAS
grafana_password   = "change-me-in-production"
EOF

echo -e "\n${GREEN}Done!${NC} Review: cat $TFVARS_FILE"
echo "Next: cd environments/$ENV && terraform init && terraform plan"
