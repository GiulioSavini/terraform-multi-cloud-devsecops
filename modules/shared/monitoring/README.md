# Shared Monitoring Module

Deploys the kube-prometheus-stack via Helm, providing a complete monitoring solution with Prometheus for metrics collection and alerting, Grafana for visualization and dashboards, and Alertmanager for alert routing and notification management.

## Usage

```hcl
module "monitoring" {
  source = "./modules/shared/monitoring"

  namespace        = "monitoring"
  create_namespace = true

  helm_chart_version = "55.5.0"

  # Prometheus
  prometheus_retention    = "30d"
  prometheus_storage_size = "100Gi"
  prometheus_storage_class = "gp3"
  prometheus_replicas     = 2
  prometheus_resources = {
    requests = {
      cpu    = "500m"
      memory = "2Gi"
    }
    limits = {
      cpu    = "2000m"
      memory = "8Gi"
    }
  }

  # Additional scrape configs
  additional_scrape_configs = [
    {
      job_name        = "vault"
      metrics_path    = "/v1/sys/metrics"
      scheme          = "https"
      params          = { format = ["prometheus"] }
      static_configs  = [{ targets = ["vault.vault.svc:8200"] }]
    }
  ]

  # Grafana
  grafana_enabled      = true
  grafana_admin_password = var.grafana_admin_password
  grafana_replicas     = 2
  grafana_storage_size = "20Gi"
  grafana_ingress_enabled = true
  grafana_ingress_host    = "grafana.example.com"
  grafana_ingress_class   = "nginx"
  grafana_plugins = [
    "grafana-piechart-panel",
    "grafana-clock-panel"
  ]
  grafana_dashboards = {
    kubernetes = {
      gnetId   = 15520
      revision = 1
    }
    node_exporter = {
      gnetId   = 1860
      revision = 33
    }
  }

  # Alertmanager
  alertmanager_enabled  = true
  alertmanager_replicas = 3
  alertmanager_config = {
    global = {
      resolve_timeout = "5m"
    }
    route = {
      group_by        = ["alertname", "namespace"]
      group_wait      = "30s"
      group_interval  = "5m"
      repeat_interval = "4h"
      receiver        = "slack"
    }
    receivers = [
      {
        name = "slack"
        slack_configs = [{
          channel     = "#alerts"
          send_resolved = true
        }]
      }
    ]
  }

  # Node Exporter
  node_exporter_enabled = true

  # kube-state-metrics
  kube_state_metrics_enabled = true

  labels = {
    environment = "production"
    project     = "multi-cloud-platform"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `namespace` | Kubernetes namespace for the monitoring stack | `string` | `"monitoring"` | no |
| `create_namespace` | Create the namespace if it does not exist | `bool` | `true` | no |
| `helm_chart_version` | Helm chart version for kube-prometheus-stack | `string` | `"55.5.0"` | no |
| `prometheus_retention` | Data retention period for Prometheus | `string` | `"30d"` | no |
| `prometheus_storage_size` | Storage size for Prometheus persistent volume | `string` | `"100Gi"` | no |
| `prometheus_storage_class` | Storage class for Prometheus persistent volume | `string` | `""` | no |
| `prometheus_replicas` | Number of Prometheus replicas | `number` | `2` | no |
| `prometheus_resources` | CPU and memory resource requests and limits for Prometheus | `object` | `{}` | no |
| `additional_scrape_configs` | Additional Prometheus scrape configurations | `list(object)` | `[]` | no |
| `grafana_enabled` | Enable Grafana | `bool` | `true` | no |
| `grafana_admin_password` | Admin password for Grafana | `string` | n/a | yes |
| `grafana_replicas` | Number of Grafana replicas | `number` | `2` | no |
| `grafana_storage_size` | Storage size for Grafana persistent volume | `string` | `"20Gi"` | no |
| `grafana_ingress_enabled` | Enable ingress for Grafana | `bool` | `false` | no |
| `grafana_ingress_host` | Hostname for Grafana ingress | `string` | `""` | no |
| `grafana_ingress_class` | Ingress class name for Grafana | `string` | `"nginx"` | no |
| `grafana_plugins` | List of Grafana plugins to install | `list(string)` | `[]` | no |
| `grafana_dashboards` | Map of Grafana dashboard configurations from grafana.com | `map(object)` | `{}` | no |
| `alertmanager_enabled` | Enable Alertmanager | `bool` | `true` | no |
| `alertmanager_replicas` | Number of Alertmanager replicas | `number` | `3` | no |
| `alertmanager_config` | Alertmanager configuration | `any` | `{}` | no |
| `node_exporter_enabled` | Enable Node Exporter | `bool` | `true` | no |
| `kube_state_metrics_enabled` | Enable kube-state-metrics | `bool` | `true` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `prometheus_namespace` | The namespace where Prometheus is deployed |
| `prometheus_service_name` | The Kubernetes service name for Prometheus |
| `prometheus_internal_url` | The internal URL for Prometheus |
| `grafana_service_name` | The Kubernetes service name for Grafana |
| `grafana_internal_url` | The internal URL for Grafana |
| `grafana_ingress_url` | The external URL for Grafana (if ingress is enabled) |
| `alertmanager_service_name` | The Kubernetes service name for Alertmanager |
| `alertmanager_internal_url` | The internal URL for Alertmanager |
