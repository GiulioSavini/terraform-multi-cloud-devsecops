# ==============================================================================
# Application: cloud foundation (phase 1 of 2)
#
# Everything that can be built with cloud provider credentials alone:
# the network fabric, cloud security services, and the Kubernetes control
# planes.
#
# The in-cluster contexts live in applications/cluster-services and are applied
# separately, because the kubernetes and helm providers cannot be configured
# against a cluster that does not exist yet. Doing both in one root is a common
# arrangement and it fails on a clean apply — see the README.
# ==============================================================================

locals {
  contexts = ["networking", "access-control", "cluster-platform"]

  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

module "tags" {
  for_each = toset(local.contexts)
  source   = "../../platform/tagging"

  landing_zone        = var.landing_zone
  environment         = var.environment
  context             = each.key
  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification
}

module "networking" {
  source = "../../domains/networking"

  landing_zone  = var.landing_zone
  environment   = var.environment
  clouds        = var.clouds
  address_space = var.address_space

  placement = {
    aws   = { region = var.aws_region }
    azure = local.azure_enabled ? { location = var.azure_location } : null
    gcp   = local.gcp_enabled ? { region = var.gcp_region } : null
  }

  tags = module.tags["networking"].tags
}

module "access_control" {
  source = "../../domains/access-control"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  networks     = module.networking.networks

  placement = {
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = module.networking.azure_resource_group_name
    } : null
    gcp = local.gcp_enabled ? { project_id = var.gcp_project_id } : null
  }

  log_analytics_workspace_id = var.log_analytics_workspace_id
  waf_rate_limit             = var.waf_rate_limit

  tags = module.tags["access-control"].tags
}

module "cluster_platform" {
  source = "../../domains/cluster-platform"

  landing_zone       = var.landing_zone
  environment        = var.environment
  clouds             = var.clouds
  networks           = module.networking.networks
  gcp_cluster_ranges = module.networking.gcp_cluster_ranges

  placement = {
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = module.networking.azure_resource_group_name
    } : null
    gcp = local.gcp_enabled ? { region = var.gcp_region } : null
  }

  kubernetes_version     = var.kubernetes_version
  node_capacity          = var.node_capacity
  endpoint_public_access = var.endpoint_public_access
  log_retention_days     = var.log_retention_days

  tags = module.tags["cluster-platform"].tags
}

module "controls" {
  source = "../../compliance/controls"
}
