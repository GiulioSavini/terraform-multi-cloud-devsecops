# =============================================================================
# Azure Infrastructure - Dev Environment
# Networking, AKS, Security, and Ingress modules
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

  project            = var.project
  environment        = var.environment
  location           = var.azure_location
  resource_group_name = module.azure_networking.resource_group_name
  cluster_name       = "${local.name_prefix}-aks"
  kubernetes_version = "1.29"

  vnet_subnet_id = module.azure_networking.aks_subnet_id

  system_node_count    = var.azure_aks_node_count
  system_node_vm_size  = var.azure_aks_node_vm_size
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
