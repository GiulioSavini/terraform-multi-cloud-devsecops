# -----------------------------------------------------------------------------
# OPA Gatekeeper Module
# Deploys OPA Gatekeeper for policy enforcement on Kubernetes clusters.
# Policies are defined as ConstraintTemplates and Constraints in the
# policies/ directory.
# -----------------------------------------------------------------------------

resource "helm_release" "gatekeeper" {
  name             = "gatekeeper"
  repository       = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart            = "gatekeeper"
  namespace        = var.namespace
  create_namespace = true
  version          = "3.15.1"
  timeout          = 600

  # Controller Manager
  set {
    name  = "replicas"
    value = tostring(var.replicas)
  }

  set {
    name  = "controllerManager.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controllerManager.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "controllerManager.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controllerManager.resources.limits.memory"
    value = "512Mi"
  }

  # Audit
  set {
    name  = "audit.replicas"
    value = "1"
  }

  set {
    name  = "audit.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "audit.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "audit.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "audit.resources.limits.memory"
    value = "512Mi"
  }

  # Emit admission events
  set {
    name  = "emitAdmissionEvents"
    value = "true"
  }

  set {
    name  = "emitAuditEvents"
    value = "true"
  }

  # Log denies for observability
  set {
    name  = "logDenies"
    value = "true"
  }
}
