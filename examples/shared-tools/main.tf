# =============================================================================
# Shared Tools Example
# Deploys Vault + Gatekeeper + Prometheus/Grafana + Linkerd on existing cluster
# =============================================================================
#
# Usage:
#   # First, make sure kubectl is configured to point to your cluster
#   kubectl cluster-info
#   terraform init
#   terraform apply
#
# This example assumes you already have a running K8s cluster.
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    helm       = { source = "hashicorp/helm", version = "~> 2.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    tls        = { source = "hashicorp/tls", version = "~> 4.0" }
  }
}

# Uses current kubeconfig context
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

variable "environment" { type = string; default = "dev" }
variable "grafana_password" { type = string; sensitive = true; default = "admin" }

# --- HashiCorp Vault (single instance for dev) ---
module "vault" {
  source = "../../modules/shared/vault"

  environment  = var.environment
  replicas     = 1
  storage_size = "5Gi"
}

# --- OPA Gatekeeper (policy enforcement) ---
module "gatekeeper" {
  source = "../../modules/shared/gatekeeper"

  environment = var.environment
}

# --- Prometheus + Grafana + Alertmanager ---
module "monitoring" {
  source = "../../modules/shared/monitoring"

  environment            = var.environment
  grafana_admin_password = var.grafana_password
  retention              = "7d"
}

# --- Linkerd Service Mesh ---
module "service_mesh" {
  source = "../../modules/shared/service-mesh"

  environment = var.environment
}

output "grafana_url" {
  value = "kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring"
}

output "vault_url" {
  value = "kubectl port-forward svc/vault 8200:8200 -n vault"
}

output "linkerd_dashboard" {
  value = "kubectl port-forward svc/web 8084:8084 -n linkerd-viz"
}

output "apply_gatekeeper_policies" {
  value = "kubectl apply -f ../../modules/shared/gatekeeper/policies/"
}
