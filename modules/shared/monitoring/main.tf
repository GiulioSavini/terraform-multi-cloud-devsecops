resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "58.2.1"

  set {
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
    name  = "prometheus.prometheusSpec.retention"
    value = var.retention
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
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
    value = "5Gi"
  }
  set {
    name  = "prometheus.prometheusSpec.replicas"
    value = var.environment == "prd" ? "2" : "1"
  }
  set {
    name  = "alertmanager.alertmanagerSpec.replicas"
    value = var.environment == "prd" ? "2" : "1"
  }
  set {
    name  = "grafana.replicas"
    value = var.environment == "prd" ? "2" : "1"
  }
}
