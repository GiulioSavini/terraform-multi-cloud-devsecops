# =============================================================================
# Complete DevSecOps Platform Example
# Deploys EKS + AKS + GKE with Vault, Gatekeeper, Prometheus, Linkerd
# =============================================================================
#
# Usage:
#   cp terraform.tfvars.example terraform.tfvars
#   terraform init
#   terraform plan -out=tfplan
#   terraform apply tfplan
#
# Prerequisites:
#   - AWS/Azure/GCP CLIs authenticated
#   - kubectl installed
#   - helm installed (optional, Terraform handles Helm releases)
#
# Estimated cost: ~$300/month (dev sizing)
# Deploy time: ~25-35 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    azurerm    = { source = "hashicorp/azurerm", version = "~> 3.0" }
    google     = { source = "hashicorp/google", version = "~> 5.0" }
    helm       = { source = "hashicorp/helm", version = "~> 2.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    tls        = { source = "hashicorp/tls", version = "~> 4.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Configure Helm/K8s providers for EKS after cluster creation
provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

locals {
  project     = "devsecops-example"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment, ManagedBy = "terraform" }
}

# =============================================================================
# AWS: EKS + Networking + Security
# =============================================================================

module "aws_networking" {
  source = "../../modules/aws/networking"

  project            = local.project
  environment        = local.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  single_nat_gateway = true
  tags               = local.tags
}

module "eks" {
  source = "../../modules/aws/eks"

  project             = local.project
  environment         = local.environment
  vpc_id              = module.aws_networking.vpc_id
  private_subnet_ids  = module.aws_networking.private_subnet_ids
  node_instance_types = ["t3.medium"]
  node_min_size       = 1
  node_max_size       = 3
  node_desired_size   = 2
  tags                = local.tags
}

module "aws_security" {
  source = "../../modules/aws/security"

  project     = local.project
  environment = local.environment
  tags        = local.tags
}

# EKS add-ons: ALB controller, cert-manager, external-dns
module "aws_ingress" {
  source = "../../modules/aws/ingress"

  providers = { helm = helm.eks, kubernetes = kubernetes }

  project                 = local.project
  environment             = local.environment
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
  vpc_id                  = module.aws_networking.vpc_id
  tags                    = local.tags
}

# =============================================================================
# Shared Tools (deployed on EKS in this example)
# =============================================================================

module "vault" {
  source = "../../modules/shared/vault"

  providers = { helm = helm.eks }

  environment  = local.environment
  replicas     = 1 # dev: single instance
  storage_size = "5Gi"
}

module "gatekeeper" {
  source = "../../modules/shared/gatekeeper"

  providers = { helm = helm.eks }

  environment = local.environment
}

module "monitoring" {
  source = "../../modules/shared/monitoring"

  providers = { helm = helm.eks }

  environment            = local.environment
  grafana_admin_password = var.grafana_password
}

module "service_mesh" {
  source = "../../modules/shared/service-mesh"

  providers = { helm = helm.eks }

  environment = local.environment
}

# =============================================================================
# Variables & Outputs
# =============================================================================

variable "aws_region" { type = string; default = "eu-west-1" }
variable "azure_subscription_id" { type = string }
variable "gcp_project_id" { type = string }
variable "gcp_region" { type = string; default = "europe-west1" }
variable "grafana_password" { type = string; sensitive = true; default = "admin" }

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_kubeconfig_cmd" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "grafana_access" {
  value = "kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring"
}

output "vault_access" {
  value = "kubectl port-forward svc/vault 8200:8200 -n vault"
}
