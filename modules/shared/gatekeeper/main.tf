resource "helm_release" "gatekeeper" {
  name             = "gatekeeper"
  repository       = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart            = "gatekeeper"
  namespace        = "gatekeeper-system"
  create_namespace = true
  version          = "3.15.1"

  set {
    name  = "replicas"
    value = var.environment == "prd" ? "3" : "1"
  }
  set {
    name  = "audit.replicas"
    value = "1"
  }
  set {
    name  = "controllerManager.resources.requests.cpu"
    value = "100m"
  }
  set {
    name  = "controllerManager.resources.requests.memory"
    value = "256Mi"
  }
}
