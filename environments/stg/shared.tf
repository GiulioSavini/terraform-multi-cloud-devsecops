# =============================================================================
# Shared Services - Staging Environment
# Vault, Gatekeeper, Monitoring, and Service Mesh (deployed to AWS EKS as primary)
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

  environment            = var.environment
  retention_days         = var.monitoring_retention_days
  grafana_admin_password = var.grafana_admin_password

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
