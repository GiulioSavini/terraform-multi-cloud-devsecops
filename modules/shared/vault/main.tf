resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  version          = "0.27.0"

  set {
    name  = "server.ha.enabled"
    value = var.environment == "prd" ? "true" : "false"
  }
  set {
    name  = "server.ha.replicas"
    value = var.environment == "prd" ? tostring(var.replicas) : "1"
  }
  set {
    name  = "server.ha.raft.enabled"
    value = "true"
  }
  set {
    name  = "server.ha.raft.setNodeId"
    value = "true"
  }
  set {
    name  = "server.dataStorage.size"
    value = var.storage_size
  }
  set {
    name  = "server.auditStorage.enabled"
    value = "true"
  }
  set {
    name  = "server.auditStorage.size"
    value = "10Gi"
  }
  set {
    name  = "injector.enabled"
    value = "true"
  }
  set {
    name  = "csi.enabled"
    value = "true"
  }
  set {
    name  = "ui.enabled"
    value = "true"
  }
  set {
    name  = "server.resources.requests.cpu"
    value = "250m"
  }
  set {
    name  = "server.resources.requests.memory"
    value = "256Mi"
  }
}
