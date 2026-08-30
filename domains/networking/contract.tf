# ------------------------------------------------------------------------------
# Bounded context: networking
#
# Owns the fabric the clusters are placed into: address space, subnets and the
# egress path. It is the first context applied and depends on nothing else.
#
# On Azure it also owns the resource group, because every Azure resource in
# this platform is placed into it and no single downstream context can claim it.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = !local.aws_enabled || var.placement.aws != null
      error_message = "placement.aws is required when aws is in scope."
    }
    precondition {
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is in scope."
    }
    precondition {
      condition     = !local.gcp_enabled || var.placement.gcp != null
      error_message = "placement.gcp is required when gcp is in scope."
    }
    precondition {
      condition = !(local.aws_enabled && local.azure_enabled) || (
        cidrhost(var.address_space.aws, 0) != cidrhost(var.address_space.azure, 0)
      )
      error_message = "address_space.aws and address_space.azure must not overlap; cluster-to-cluster traffic would blackhole at runtime with no build error."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project     = var.landing_zone
  environment = var.environment
  vpc_cidr    = var.address_space.aws
  aws_region  = var.placement.aws.region
  common_tags = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project     = var.landing_zone
  environment = var.environment
  location    = var.placement.azure.location
  vnet_cidr   = var.address_space.azure
  common_tags = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project     = var.landing_zone
  environment = var.environment
  region      = var.placement.gcp.region
  vpc_cidr    = var.address_space.gcp

  depends_on = [terraform_data.guards]
}
