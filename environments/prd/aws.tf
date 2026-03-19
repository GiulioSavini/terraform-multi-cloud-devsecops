# =============================================================================
# AWS Infrastructure - Production Environment
# Networking, EKS, Security, and Ingress modules
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
  node_min_count     = 3
  node_instance_type = var.aws_eks_node_instance_type
  node_disk_size     = 100

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
