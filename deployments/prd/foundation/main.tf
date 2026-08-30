# ==============================================================================
# Deployment: prd / foundation (phase 1)
#
# Apply this before prd/services-*. Those roots read this state to configure
# their kubernetes and helm providers.
# ==============================================================================

module "foundation" {
  source = "../../../applications/cloud-foundation"

  landing_zone = "devsecops"
  environment  = "prd"
  clouds       = ["aws", "azure", "gcp"]

  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification

  aws_region     = var.aws_region
  azure_location = "westeurope"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  kubernetes_version     = "1.30"
  node_capacity          = { min = 3, desired = 4, max = 20 }
  endpoint_public_access = false
  log_retention_days     = 365

  log_analytics_workspace_id = var.log_analytics_workspace_id
}
