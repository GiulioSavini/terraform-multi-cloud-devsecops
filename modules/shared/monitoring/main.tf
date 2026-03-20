# -----------------------------------------------------------------------------
# Monitoring Module
# kube-prometheus-stack: Prometheus + Grafana + Alertmanager
# -----------------------------------------------------------------------------

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.namespace
  create_namespace = true
  version          = "58.2.2"
  timeout          = 900

  # ─── Grafana ────────────────────────────────────────────────
  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.size"
    value = "10Gi"
  }

  set {
    name  = "grafana.persistence.storageClassName"
    value = var.storage_class
  }

  set {
    name  = "grafana.replicas"
    value = var.environment == "prd" ? "2" : "1"
  }

  set {
    name  = "grafana.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "grafana.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "grafana.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "grafana.resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "grafana.sidecar.dashboards.enabled"
    value = "true"
  }

  set {
    name  = "grafana.sidecar.dashboards.searchNamespace"
    value = "ALL"
  }

  # ─── Prometheus ─────────────────────────────────────────────
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "${var.retention_days}d"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.environment == "prd" ? "100Gi" : "20Gi"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = var.storage_class
  }

  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = var.environment == "prd" ? "2" : "1"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.cpu"
    value = "200m"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.limits.cpu"
    value = "2"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.limits.memory"
    value = "4Gi"
  }

  # Enable service monitors for auto-discovery
  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  # ─── Alertmanager ───────────────────────────────────────────
  set {
    name  = "alertmanager.alertmanagerSpec.replicas"
    value = var.environment == "prd" ? "2" : "1"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
    value = "5Gi"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName"
    value = var.storage_class
  }

  set {
    name  = "alertmanager.alertmanagerSpec.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "alertmanager.alertmanagerSpec.resources.requests.memory"
    value = "64Mi"
  }

  # ─── Node Exporter ─────────────────────────────────────────
  set {
    name  = "nodeExporter.enabled"
    value = "true"
  }

  # ─── kube-state-metrics ────────────────────────────────────
  set {
    name  = "kubeStateMetrics.enabled"
    value = "true"
  }
}
