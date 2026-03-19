# ─── Locals ───────────────────────────────────────────────────
locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Platform    = "devsecops-multi-cloud"
  }
}

# =============================================================================
# AWS Infrastructure
# =============================================================================

module "aws_networking" {
  source = "../../modules/aws/networking"

  project     = var.project
  environment = var.environment
  vpc_cidr    = var.aws_vpc_cidr
  aws_region  = var.aws_region
  common_tags = local.common_tags
}

module "aws_eks" {
  source = "../../modules/aws/eks"

  project            = var.project
  environment        = var.environment
  cluster_name       = "${local.name_prefix}-eks"
  kubernetes_version = "1.29"

  vpc_id             = module.aws_networking.vpc_id
  private_subnet_ids = module.aws_networking.private_subnet_ids

  node_desired_count = var.aws_eks_node_count
  node_max_count     = var.aws_eks_node_max_count
  node_min_count     = 2
  node_instance_type = var.aws_eks_node_instance_type
  node_disk_size     = 80

  common_tags = local.common_tags

  depends_on = [module.aws_networking]
}

module "aws_security" {
  source = "../../modules/aws/security"

  project     = var.project
  environment = var.environment
  common_tags = local.common_tags
}

module "aws_ingress" {
  source = "../../modules/aws/ingress"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  cluster_name        = module.aws_eks.cluster_name
  cluster_oidc_issuer = module.aws_eks.oidc_issuer_url
  vpc_id              = module.aws_networking.vpc_id
  aws_region          = var.aws_region
  domain_name         = var.domain_name
  letsencrypt_email   = var.letsencrypt_email
  oidc_provider_arn   = module.aws_eks.oidc_provider_arn

  depends_on = [module.aws_eks]
}

# =============================================================================
# Azure Infrastructure
# =============================================================================

module "azure_networking" {
  source = "../../modules/azure/networking"

  project     = var.project
  environment = var.environment
  location    = var.azure_location
  vnet_cidr   = var.azure_vnet_cidr
  common_tags = local.common_tags
}

module "azure_aks" {
  source = "../../modules/azure/aks"

  project             = var.project
  environment         = var.environment
  location            = var.azure_location
  resource_group_name = module.azure_networking.resource_group_name
  cluster_name        = "${local.name_prefix}-aks"
  kubernetes_version  = "1.29"

  vnet_subnet_id = module.azure_networking.aks_subnet_id

  system_node_count     = var.azure_aks_node_count
  system_node_vm_size   = var.azure_aks_node_vm_size
  system_node_max_count = var.azure_aks_node_max_count

  common_tags = local.common_tags

  depends_on = [module.azure_networking]
}

module "azure_security" {
  source = "../../modules/azure/security"

  project             = var.project
  environment         = var.environment
  location            = var.azure_location
  resource_group_name = module.azure_networking.resource_group_name
  common_tags         = local.common_tags
}

module "azure_ingress" {
  source = "../../modules/azure/ingress"

  providers = {
    kubernetes = kubernetes.aks
    helm       = helm.aks
  }

  domain_name       = var.domain_name
  letsencrypt_email = var.letsencrypt_email

  depends_on = [module.azure_aks]
}

# =============================================================================
# GCP Infrastructure
# =============================================================================

module "gcp_networking" {
  source = "../../modules/gcp/networking"

  project     = var.project
  environment = var.environment
  region      = var.gcp_region
  vpc_cidr    = var.gcp_vpc_cidr
}

module "gcp_gke" {
  source = "../../modules/gcp/gke"

  project            = var.project
  environment        = var.environment
  region             = var.gcp_region
  cluster_name       = "${local.name_prefix}-gke"
  kubernetes_version = "1.29"

  network             = module.gcp_networking.network_name
  subnetwork          = module.gcp_networking.subnet_name
  pods_range_name     = module.gcp_networking.pods_range_name
  services_range_name = module.gcp_networking.services_range_name

  node_count        = var.gcp_gke_node_count
  node_max_count    = var.gcp_gke_node_max_count
  node_min_count    = 2
  node_machine_type = var.gcp_gke_node_machine_type
  node_disk_size_gb = 80

  regional = true

  depends_on = [module.gcp_networking]
}

module "gcp_security" {
  source = "../../modules/gcp/security"

  project        = var.project
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
}

module "gcp_ingress" {
  source = "../../modules/gcp/ingress"

  providers = {
    kubernetes = kubernetes.gke
    helm       = helm.gke
  }

  domain_name       = var.domain_name
  letsencrypt_email = var.letsencrypt_email
  gcp_project_id    = var.gcp_project_id

  depends_on = [module.gcp_gke]
}

# =============================================================================
# Shared Services (deployed to AWS EKS as primary)
# =============================================================================

module "vault" {
  source = "../../modules/shared/vault"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  replicas    = var.vault_replicas
  environment = var.environment

  depends_on = [module.aws_eks]
}

module "gatekeeper" {
  source = "../../modules/shared/gatekeeper"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  depends_on = [module.aws_eks]
}

module "monitoring" {
  source = "../../modules/shared/monitoring"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  environment    = var.environment
  retention_days = var.monitoring_retention_days

  depends_on = [module.aws_eks]
}

module "service_mesh" {
  source = "../../modules/shared/service-mesh"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  depends_on = [module.aws_eks]
}
