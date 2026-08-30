# ==============================================================================
# Deployment: stg / foundation (phase 1)
#
# Apply this before stg/services-*. Those roots read this state to configure
# their kubernetes and helm providers.
# ==============================================================================

module "foundation" {
  source = "../../../applications/cloud-foundation"

  landing_zone = "devsecops"
  environment  = "stg"
  clouds       = ["aws", "azure"]

  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification

  aws_region     = var.aws_region
  azure_location = "westeurope"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  kubernetes_version     = "1.30"
  node_capacity          = { min = 2, desired = 3, max = 8 }
  endpoint_public_access = true
  log_retention_days     = 180

  log_analytics_workspace_id = var.log_analytics_workspace_id
}
