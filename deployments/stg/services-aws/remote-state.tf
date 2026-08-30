# The foundation's state is read as a data source, which resolves at plan time.
# That is what makes the kubernetes and helm providers below configurable —
# referencing a module output in the same root would not, because the cluster
# does not exist when the provider is initialised.
data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket = "devsecops-tfstate-stg"
    key    = "stg/foundation.tfstate"
    region = "eu-west-1"
  }
}

locals {
  cloud   = "aws"
  cluster = data.terraform_remote_state.foundation.outputs.clusters[local.cloud]
}
