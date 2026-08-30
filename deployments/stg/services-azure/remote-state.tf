# The foundation's state resolves at plan time, which is what makes the
# kubernetes and helm providers below configurable. Referencing a module output
# in this same root would not: the cluster does not exist when the provider is
# initialised.
data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = "devsecops-tfstate-stg"
    key    = "stg/foundation.tfstate"
    region = "eu-west-1"
  }
}

locals {
  cloud        = "azure"
  cluster_name = data.terraform_remote_state.foundation.outputs.cluster_names[local.cloud]
}

# AKS credentials come from the cluster itself rather than from the foundation
# state, so cluster-admin certificates are never written into two state files.
data "azurerm_kubernetes_cluster" "this" {
  name                = local.cluster_name
  resource_group_name = var.azure_resource_group_name
}
