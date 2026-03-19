# Shared Service Mesh Module

Deploys Linkerd as a lightweight service mesh providing mutual TLS (mTLS) for automatic encryption of inter-service communication, observability with golden metrics, and traffic reliability features including retries and timeouts.

## Usage

```hcl
module "service_mesh" {
  source = "./modules/shared/service-mesh"

  namespace        = "linkerd"
  create_namespace = true

  linkerd_chart_version     = "1.16.11"
  linkerd_viz_chart_version = "30.8.5"

  # Trust anchor certificate
  trust_anchor_cert     = file("${path.module}/certs/ca.crt")
  trust_anchor_key      = file("${path.module}/certs/ca.key")
  identity_issuer_cert  = file("${path.module}/certs/issuer.crt")
  identity_issuer_key   = file("${path.module}/certs/issuer.key")

  # Control plane configuration
  control_plane_replicas = 3
  control_plane_resources = {
    proxy = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "1000m"
        memory = "256Mi"
      }
    }
    destination = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "1000m"
        memory = "512Mi"
      }
    }
  }

  # Proxy configuration
  proxy_cpu_request    = "100m"
  proxy_cpu_limit      = "1000m"
  proxy_memory_request = "128Mi"
  proxy_memory_limit   = "256Mi"
  proxy_log_level      = "warn,linkerd=info"

  # Linkerd Viz (observability dashboard)
  enable_viz = true
  viz_ingress_enabled    = true
  viz_ingress_host       = "linkerd.example.com"
  viz_ingress_class_name = "nginx"

  # Automatic proxy injection
  auto_inject_namespaces = [
    "default",
    "application",
    "api"
  ]

  # High availability
  enable_ha = true

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
| `namespace` | Kubernetes namespace for Linkerd | `string` | `"linkerd"` | no |
| `create_namespace` | Create the namespace if it does not exist | `bool` | `true` | no |
| `linkerd_chart_version` | Helm chart version for Linkerd control plane | `string` | `"1.16.11"` | no |
| `linkerd_viz_chart_version` | Helm chart version for Linkerd Viz | `string` | `"30.8.5"` | no |
| `trust_anchor_cert` | Trust anchor TLS certificate (PEM) | `string` | n/a | yes |
| `trust_anchor_key` | Trust anchor TLS private key (PEM) | `string` | n/a | yes |
| `identity_issuer_cert` | Identity issuer TLS certificate (PEM) | `string` | n/a | yes |
| `identity_issuer_key` | Identity issuer TLS private key (PEM) | `string` | n/a | yes |
| `control_plane_replicas` | Number of control plane replicas | `number` | `3` | no |
| `control_plane_resources` | Resource requests and limits for control plane components | `map(object)` | `{}` | no |
| `proxy_cpu_request` | CPU request for the Linkerd proxy sidecar | `string` | `"100m"` | no |
| `proxy_cpu_limit` | CPU limit for the Linkerd proxy sidecar | `string` | `"1000m"` | no |
| `proxy_memory_request` | Memory request for the Linkerd proxy sidecar | `string` | `"128Mi"` | no |
| `proxy_memory_limit` | Memory limit for the Linkerd proxy sidecar | `string` | `"256Mi"` | no |
| `proxy_log_level` | Log level for the Linkerd proxy | `string` | `"warn,linkerd=info"` | no |
| `enable_viz` | Enable Linkerd Viz dashboard | `bool` | `true` | no |
| `viz_ingress_enabled` | Enable ingress for Linkerd Viz dashboard | `bool` | `false` | no |
| `viz_ingress_host` | Hostname for Linkerd Viz ingress | `string` | `""` | no |
| `viz_ingress_class_name` | Ingress class name for Linkerd Viz | `string` | `"nginx"` | no |
| `auto_inject_namespaces` | List of namespaces to enable automatic proxy injection | `list(string)` | `[]` | no |
| `enable_ha` | Enable high availability mode for the control plane | `bool` | `true` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `linkerd_namespace` | The namespace where Linkerd is deployed |
| `linkerd_version` | The deployed version of Linkerd |
| `viz_namespace` | The namespace where Linkerd Viz is deployed |
| `viz_dashboard_url` | The URL for the Linkerd Viz dashboard (if ingress is enabled) |
| `trust_anchor_expiry` | The expiry date of the trust anchor certificate |
| `identity_issuer_expiry` | The expiry date of the identity issuer certificate |
