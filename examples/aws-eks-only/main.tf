# =============================================================================
# AWS EKS-Only Example
# Deploys: VPC + EKS cluster + WAF + GuardDuty + ALB Ingress
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply
#   aws eks update-kubeconfig --name $(terraform output -raw cluster_name)
#   kubectl get nodes
#
# Estimated cost: ~$100/month
# Deploy time: ~15 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws  = { source = "hashicorp/aws", version = "~> 5.0" }
    tls  = { source = "hashicorp/tls", version = "~> 4.0" }
    helm = { source = "hashicorp/helm", version = "~> 2.0" }
  }
}

provider "aws" {
  region = "eu-west-1"
}

locals {
  project     = "eks-example"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment }
}

module "networking" {
  source = "../../modules/aws/networking"

  project            = local.project
  environment        = local.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  single_nat_gateway = true
  tags               = local.tags
}

module "eks" {
  source = "../../modules/aws/eks"

  project             = local.project
  environment         = local.environment
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  node_instance_types = ["t3.medium"]
  node_min_size       = 1
  node_max_size       = 3
  node_desired_size   = 2
  tags                = local.tags
}

module "security" {
  source = "../../modules/aws/security"

  project     = local.project
  environment = local.environment
  tags        = local.tags
}

output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "kubeconfig_cmd" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region eu-west-1"
}
