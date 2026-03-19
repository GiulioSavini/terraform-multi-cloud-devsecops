# =============================================================================
# GCP Infrastructure - Production Environment
# Networking, GKE, Security, and Ingress modules
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
  node_min_count    = 3
  node_machine_type = var.gcp_gke_node_machine_type
  node_disk_size_gb = 100

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
