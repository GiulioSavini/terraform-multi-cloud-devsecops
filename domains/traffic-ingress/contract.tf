# ------------------------------------------------------------------------------
# Bounded context: traffic-ingress
#
# Owns how external traffic reaches a workload: ingress controllers, the load
# balancer wiring, certificate issuance and external DNS.
#
# It consumes cluster handles from cluster-platform and the fabric from
# networking; it creates neither.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.cluster_names)))) == 0
      error_message = "Every cloud in clouds must have a cluster. Ingress cannot be installed without one."
    }
    precondition {
      condition     = !local.aws_enabled || var.aws_irsa != null
      error_message = "aws_irsa is required when aws is in scope. The load balancer controller assumes a role through IRSA and cannot function without it."
    }
    precondition {
      condition     = !local.gcp_enabled || var.placement.gcp != null
      error_message = "placement.gcp is required when gcp is in scope."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  cluster_name        = var.cluster_names["aws"]
  cluster_oidc_issuer = var.aws_irsa.oidc_issuer_url
  oidc_provider_arn   = var.aws_irsa.oidc_provider_arn
  vpc_id              = var.networks["aws"].id
  aws_region          = var.placement.aws.region
  common_tags         = var.tags

  domain_name       = var.domain_name
  letsencrypt_email = var.letsencrypt_email

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  domain_name       = var.domain_name
  letsencrypt_email = var.letsencrypt_email

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  gcp_project_id    = var.placement.gcp.project_id
  domain_name       = var.domain_name
  letsencrypt_email = var.letsencrypt_email

  depends_on = [terraform_data.guards]
}
