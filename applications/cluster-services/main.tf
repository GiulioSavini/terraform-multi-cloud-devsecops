# ==============================================================================
# Application: cluster services (phase 2 of 2)
#
# Everything that runs inside one Kubernetes cluster. Applied after
# applications/cloud-foundation has created that cluster, against a kubernetes
# and helm provider configured in the deployment root from the foundation's
# remote state.
#
# One deployment per cluster. The kubernetes provider addresses exactly one API
# server, and fanning a single root across three clusters would require provider
# aliases threaded through every module — which couples each module to the
# multi-cloud arrangement instead of to its own domain.
# ==============================================================================

locals {
  contexts = ["traffic-ingress", "policy-enforcement", "secrets-management", "observability", "service-mesh"]
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

module "traffic_ingress" {
  source = "../../domains/traffic-ingress"

  clouds        = [var.cloud]
  networks      = var.networks
  cluster_names = { (var.cloud) = var.cluster_name }
  aws_irsa      = var.aws_irsa

  placement = {
    aws = var.cloud == "aws" ? { region = var.aws_region } : null
    gcp = var.cloud == "gcp" ? { project_id = var.gcp_project_id } : null
  }

  domain_name       = var.domain_name
  letsencrypt_email = var.letsencrypt_email

  tags = module.tags["traffic-ingress"].tags
}

module "policy_enforcement" {
  source = "../../domains/policy-enforcement"

  environment = var.environment
  replicas    = var.gatekeeper_replicas
}

module "secrets_management" {
  source = "../../domains/secrets-management"

  environment   = var.environment
  replicas      = var.vault_replicas
  storage_class = var.vault_storage_class
}

module "observability" {
  source = "../../domains/observability"

  environment            = var.environment
  grafana_admin_password = var.grafana_admin_password
  retention_days         = var.metrics_retention_days
  storage_class          = var.metrics_storage_class
}

module "service_mesh" {
  source = "../../domains/service-mesh"

  environment = var.environment
  replicas    = var.mesh_replicas

  # The observability context already runs Prometheus. A second one scraping
  # the same targets doubles the cost and disagrees during incidents.
  enable_viz_prometheus = false
}
