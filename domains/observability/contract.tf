# ------------------------------------------------------------------------------
# Bounded context: observability
#
# Owns in-cluster metrics, dashboards and alerting: the Prometheus/Grafana
# stack. Cloud-native logging and threat detection belong to access-control;
# this context is what runs inside the cluster.
# ------------------------------------------------------------------------------

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = var.environment != "prd" || var.retention_days >= 90
      error_message = "retention_days must be at least 90 in prd. Capacity planning and incident review both need a quarter of history."
    }
    precondition {
      condition     = var.environment != "prd" || length(var.storage_class) > 0
      error_message = "storage_class must be set explicitly in prd. Falling back to the cluster default silently binds production metrics to whatever class the cluster happens to ship."
    }
  }
}

module "kubernetes" {
  source = "./kubernetes"

  environment            = var.environment
  namespace              = var.namespace
  grafana_admin_password = var.grafana_admin_password
  retention_days         = var.retention_days
  storage_class          = var.storage_class

  depends_on = [terraform_data.guards]
}
