# ------------------------------------------------------------------------------
# Bounded context: policy-enforcement
#
# Owns admission control inside the cluster: Gatekeeper and its constraint
# templates. There is one adapter because the implementation is Kubernetes, not
# a cloud — the context spans every cluster the platform runs.
#
# This is admission-time enforcement, distinct from the plan-time policy in
# compliance/policies. Both exist because they catch different things: plan-time
# policy catches what Terraform is about to create, admission control catches
# what anyone applies to the cluster afterwards.
# ------------------------------------------------------------------------------

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = var.environment != "prd" || var.replicas >= 2
      error_message = "replicas must be at least 2 in prd. A single Gatekeeper replica is a single point of failure on the admission path, and its outage blocks every deployment."
    }
  }
}

module "kubernetes" {
  source = "./kubernetes"

  namespace = var.namespace
  replicas  = var.replicas

  depends_on = [terraform_data.guards]
}
