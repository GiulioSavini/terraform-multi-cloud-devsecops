# ==============================================================================
# Deployment: stg / services on the azure cluster (phase 2)
#
# Requires stg/foundation to have been applied first.
# ==============================================================================

module "services" {
  source = "../../../applications/cluster-services"

  landing_zone = "devsecops"
  environment  = "stg"
  cloud        = local.cloud

  cluster_name = data.terraform_remote_state.foundation.outputs.cluster_names[local.cloud]
  networks     = data.terraform_remote_state.foundation.outputs.networks
  aws_irsa     = null

  aws_region     = var.aws_region
  gcp_project_id = var.gcp_project_id

  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification

  domain_name            = var.domain_name
  letsencrypt_email      = var.letsencrypt_email
  grafana_admin_password = var.grafana_admin_password

  vault_replicas         = 3
  gatekeeper_replicas    = 2
  mesh_replicas          = 2
  metrics_retention_days = 30
  metrics_storage_class  = ""
}
