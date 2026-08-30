# ------------------------------------------------------------------------------
# Bounded context: service-mesh
#
# Owns pod-to-pod mTLS and traffic policy: Linkerd and its trust anchor.
# ------------------------------------------------------------------------------

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = var.environment != "prd" || var.replicas >= 3
      error_message = "replicas must be at least 3 in prd. The Linkerd control plane issues certificates, and an outage stops new pods from joining the mesh."
    }
  }
}

module "kubernetes" {
  source = "./kubernetes"

  replicas              = var.replicas
  enable_viz_prometheus = var.enable_viz_prometheus

  depends_on = [terraform_data.guards]
}
