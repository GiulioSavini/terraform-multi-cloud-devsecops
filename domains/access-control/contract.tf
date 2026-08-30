# ------------------------------------------------------------------------------
# Bounded context: access-control
#
# Owns detection and edge protection: WAF and rate limiting, threat detection
# services, the managed secret store, and the identities workloads assume.
#
# It attaches to the fabric published by networking and creates no networks.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.networks)))) == 0
      error_message = "Every cloud in clouds must exist in networks."
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
      condition     = var.environment != "prd" || !local.azure_enabled || length(var.log_analytics_workspace_id) > 0
      error_message = "log_analytics_workspace_id is required in prd. Security diagnostics with no destination produce no evidence for ISO 27001 A.8.15 or NIS2 Art. 21."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project        = var.landing_zone
  environment    = var.environment
  waf_rate_limit = var.waf_rate_limit
  common_tags    = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project                    = var.landing_zone
  environment                = var.environment
  location                   = var.placement.azure.location
  resource_group_name        = var.placement.azure.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  allowed_subnet_ids         = var.networks["azure"].private_subnets
  common_tags                = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project        = var.landing_zone
  environment    = var.environment
  gcp_project_id = var.placement.gcp.project_id

  depends_on = [terraform_data.guards]
}
