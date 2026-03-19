# GCP Ingress Module

Deploys the NGINX Ingress Controller for Kubernetes ingress management on GKE, cert-manager for automated TLS certificate provisioning via Let's Encrypt, and external-dns for automatic DNS record management in Cloud DNS.

## Usage

```hcl
module "ingress" {
  source = "./modules/gcp/ingress"

  project_id   = "my-gcp-project"
  cluster_name = module.gke.cluster_name
  dns_zone     = "example-com"
  domain       = "example.com"

  # NGINX Ingress Controller
  enable_nginx_ingress        = true
  nginx_ingress_chart_version = "4.8.3"
  nginx_ingress_namespace     = "ingress-nginx"
  nginx_ingress_replica_count = 3
  nginx_ingress_annotations = {
    "cloud.google.com/load-balancer-type" = "Internal"
  }

  # cert-manager
  enable_cert_manager        = true
  cert_manager_chart_version = "v1.13.3"
  cert_manager_namespace     = "cert-manager"
  cert_manager_email         = "admin@example.com"
  cert_manager_issuer_type   = "ClusterIssuer"
  cert_manager_solver        = "dns01"

  # external-dns
  enable_external_dns        = true
  external_dns_chart_version = "1.14.3"
  external_dns_namespace     = "external-dns"
  external_dns_domain_filters = ["example.com"]
  external_dns_policy        = "sync"

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
| `project_id` | GCP project ID | `string` | n/a | yes |
| `cluster_name` | Name of the GKE cluster | `string` | n/a | yes |
| `dns_zone` | Cloud DNS managed zone name | `string` | n/a | yes |
| `domain` | Domain name for DNS records | `string` | n/a | yes |
| `enable_nginx_ingress` | Enable NGINX Ingress Controller | `bool` | `true` | no |
| `nginx_ingress_chart_version` | Helm chart version for NGINX ingress | `string` | `"4.8.3"` | no |
| `nginx_ingress_namespace` | Kubernetes namespace for NGINX ingress | `string` | `"ingress-nginx"` | no |
| `nginx_ingress_replica_count` | Number of NGINX ingress controller replicas | `number` | `3` | no |
| `nginx_ingress_annotations` | Annotations for the NGINX ingress service | `map(string)` | `{}` | no |
| `enable_cert_manager` | Enable cert-manager | `bool` | `true` | no |
| `cert_manager_chart_version` | Helm chart version for cert-manager | `string` | `"v1.13.3"` | no |
| `cert_manager_namespace` | Kubernetes namespace for cert-manager | `string` | `"cert-manager"` | no |
| `cert_manager_email` | Email address for Let's Encrypt registration | `string` | n/a | yes |
| `cert_manager_issuer_type` | Type of cert-manager issuer (ClusterIssuer or Issuer) | `string` | `"ClusterIssuer"` | no |
| `cert_manager_solver` | ACME challenge solver type (dns01 or http01) | `string` | `"dns01"` | no |
| `enable_external_dns` | Enable external-dns | `bool` | `true` | no |
| `external_dns_chart_version` | Helm chart version for external-dns | `string` | `"1.14.3"` | no |
| `external_dns_namespace` | Kubernetes namespace for external-dns | `string` | `"external-dns"` | no |
| `external_dns_domain_filters` | List of domain filters for external-dns | `list(string)` | `[]` | no |
| `external_dns_policy` | DNS record management policy (sync or upsert-only) | `string` | `"sync"` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `nginx_ingress_ip` | The IP address of the NGINX ingress load balancer |
| `nginx_ingress_namespace` | Namespace where NGINX ingress is deployed |
| `cert_manager_namespace` | Namespace where cert-manager is deployed |
| `external_dns_namespace` | Namespace where external-dns is deployed |
| `cert_manager_cluster_issuer_name` | Name of the cert-manager ClusterIssuer |
| `external_dns_service_account` | Service account used by external-dns |
