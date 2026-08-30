# ------------------------------------------------------------------------------
# Bounded context: cluster-platform
#
# Owns the managed Kubernetes control planes and their node pools. It is the
# seam between the cloud contexts below it and the in-cluster contexts above:
# everything downstream consumes `clusters`, not EKS, AKS or GKE.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")

  cluster_name = "${var.landing_zone}-${var.environment}"
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.networks)))) == 0
      error_message = "Every cloud in clouds must exist in networks."
    }
    precondition {
      condition     = !local.gcp_enabled || var.gcp_cluster_ranges != null
      error_message = "gcp_cluster_ranges is required when gcp is in scope. GKE addresses its pod and service ranges by name, and cannot be created without them."
    }
    precondition {
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is in scope."
    }
    precondition {
      condition     = var.environment != "prd" || !var.endpoint_public_access
      error_message = "endpoint_public_access must be false in prd. A publicly reachable API server fails CIS Kubernetes 5.x and ISO 27001 A.8.20."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project     = var.landing_zone
  environment = var.environment

  cluster_name       = local.cluster_name
  vpc_id             = var.networks["aws"].id
  private_subnet_ids = var.networks["aws"].private_subnets

  kubernetes_version     = var.kubernetes_version
  node_instance_type     = var.node_size.aws
  node_min_count         = var.node_capacity.min
  node_desired_count     = var.node_capacity.desired
  node_max_count         = var.node_capacity.max
  endpoint_public_access = var.endpoint_public_access
  log_retention_days     = var.log_retention_days

  common_tags = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project     = var.landing_zone
  environment = var.environment

  location            = var.placement.azure.location
  resource_group_name = var.placement.azure.resource_group_name
  cluster_name        = local.cluster_name
  vnet_subnet_id      = var.networks["azure"].private_subnets[0]

  kubernetes_version    = var.kubernetes_version
  system_node_vm_size   = var.node_size.azure
  system_node_count     = var.node_capacity.desired
  system_node_max_count = var.node_capacity.max

  common_tags = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project     = var.landing_zone
  environment = var.environment

  cluster_name = local.cluster_name
  region       = var.placement.gcp.region
  network      = var.gcp_cluster_ranges.network
  subnetwork   = var.gcp_cluster_ranges.subnetwork

  pods_range_name     = var.gcp_cluster_ranges.pods_range
  services_range_name = var.gcp_cluster_ranges.services_range

  kubernetes_version = var.kubernetes_version
  node_machine_type  = var.node_size.gcp
  node_min_count     = var.node_capacity.min
  node_count         = var.node_capacity.desired
  node_max_count     = var.node_capacity.max

  # Regional clusters replicate the control plane across zones. Worth the cost
  # in production and not elsewhere.
  regional = var.environment == "prd"

  depends_on = [terraform_data.guards]
}
