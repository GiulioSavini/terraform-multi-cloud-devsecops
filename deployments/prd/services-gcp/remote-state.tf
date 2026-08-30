# The foundation's state resolves at plan time, which is what makes the
# kubernetes and helm providers below configurable.
data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = "devsecops-tfstate-prd"
    key    = "prd/foundation.tfstate"
    region = "eu-west-1"
  }
}

locals {
  cloud        = "gcp"
  cluster_name = data.terraform_remote_state.foundation.outputs.cluster_names[local.cloud]
}

data "google_container_cluster" "this" {
  name     = local.cluster_name
  location = var.gcp_region
  project  = var.gcp_project_id
}

# A short-lived OAuth token for the caller. Nothing long-lived is written to
# state.
data "google_client_config" "this" {}
