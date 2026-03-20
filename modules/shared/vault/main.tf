# -----------------------------------------------------------------------------
# HashiCorp Vault Module
# Vault in HA mode with Raft storage, injector enabled, and CSI provider.
# -----------------------------------------------------------------------------

variable "tls_disable" {
  description = "Disable TLS for Vault listener (enable only in dev)"
  type        = bool
  default     = false
}

resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = var.namespace
  create_namespace = true
  version          = "0.28.0"
  timeout          = 600

  # HA Configuration
  set {
    name  = "server.ha.enabled"
    value = tostring(var.replicas > 1)
  }

  set {
    name  = "server.ha.replicas"
    value = tostring(var.replicas)
  }

  # Raft Storage Backend
  set {
    name  = "server.ha.raft.enabled"
    value = "true"
  }

  set {
    name  = "server.ha.raft.setNodeId"
    value = "true"
  }

  set {
    name  = "server.ha.raft.config"
    value = <<-EOT
      ui = true

      listener "tcp" {
        tls_disable = ${var.tls_disable ? 1 : 0}
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        telemetry {
          unauthenticated_metrics_access = "true"
        }
      }

      storage "raft" {
        path = "/vault/data"
      }

      service_registration "kubernetes" {}

      telemetry {
        prometheus_retention_time = "30s"
        disable_hostname = true
      }
    EOT
  }

  # Data Storage
  set {
    name  = "server.dataStorage.enabled"
    value = "true"
  }

  set {
    name  = "server.dataStorage.size"
    value = var.storage_size
  }

  set {
    name  = "server.dataStorage.storageClass"
    value = var.storage_class
  }

  # Audit Storage
  set {
    name  = "server.auditStorage.enabled"
    value = "true"
  }

  set {
    name  = "server.auditStorage.size"
    value = "10Gi"
  }

  # Injector
  set {
    name  = "injector.enabled"
    value = "true"
  }

  set {
    name  = "injector.replicas"
    value = var.replicas > 1 ? "2" : "1"
  }

  set {
    name  = "injector.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "injector.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "injector.resources.limits.cpu"
    value = "250m"
  }

  set {
    name  = "injector.resources.limits.memory"
    value = "256Mi"
  }

  # CSI Provider
  set {
    name  = "csi.enabled"
    value = "true"
  }

  set {
    name  = "csi.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "csi.resources.requests.memory"
    value = "64Mi"
  }

  # UI
  set {
    name  = "ui.enabled"
    value = "true"
  }

  set {
    name  = "ui.serviceType"
    value = "ClusterIP"
  }

  # Server Resources
  set {
    name  = "server.resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "512Mi"
  }

  # Prometheus Metrics
  set {
    name  = "serverTelemetry.serviceMonitor.enabled"
    value = "true"
  }
}
