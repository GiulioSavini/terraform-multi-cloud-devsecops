# =============================================================================
# GCP GKE-Only Example
# Deploys: VPC + private GKE + Cloud Armor + Workload Identity
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply -var="gcp_project_id=YOUR_PROJECT"
#   gcloud container clusters get-credentials $(terraform output -raw cluster_name) --region europe-west1
#   kubectl get nodes
#
# Estimated cost: ~$70/month
# Deploy time: ~10 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = "europe-west1"
}

variable "gcp_project_id" { type = string }

locals {
  project     = "gke-example"
  environment = "dev"
  labels      = { project = local.project, environment = local.environment }
}

module "networking" {
  source = "../../modules/gcp/networking"

  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  region         = "europe-west1"
  labels         = local.labels
}

module "gke" {
  source = "../../modules/gcp/gke"

  project             = local.project
  environment         = local.environment
  gcp_project_id      = var.gcp_project_id
  region              = "europe-west1"
  network_id          = module.networking.network_id
  subnet_id           = module.networking.subnet_id
  node_machine_type   = "e2-medium"
  node_min_count      = 1
  node_max_count      = 3
  labels              = local.labels
}

module "security" {
  source = "../../modules/gcp/security"

  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.labels
}

output "cluster_name" { value = module.gke.cluster_name }
output "kubeconfig_cmd" {
  value = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region europe-west1 --project ${var.gcp_project_id}"
}
