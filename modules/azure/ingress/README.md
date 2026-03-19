# Azure Ingress Module

Deploys the NGINX Ingress Controller for Kubernetes ingress management on AKS, cert-manager for automated TLS certificate provisioning via Let's Encrypt, and external-dns for automatic DNS record management in Azure DNS.

## Usage

```hcl
module "ingress" {
  source = "./modules/azure/ingress"

  resource_group_name = azurerm_resource_group.main.name
  cluster_name        = module.aks.cluster_name
  dns_zone_name       = "example.com"
  dns_zone_resource_group = "dns-rg"

  # NGINX Ingress Controller
  enable_nginx_ingress        = true
  nginx_ingress_chart_version = "4.8.3"
  nginx_ingress_namespace     = "ingress-nginx"
  nginx_ingress_replica_count = 3
  nginx_ingress_annotations = {
    "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" = "/healthz"
    "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
  }

  # cert-manager
  enable_cert_manager        = true
  cert_manager_chart_version = "v1.13.3"
  cert_manager_namespace     = "cert-manager"
  cert_manager_email         = "admin@example.com"
  cert_manager_issuer_type   = "ClusterIssuer"

  # external-dns
  enable_external_dns        = true
  external_dns_chart_version = "1.14.3"
  external_dns_namespace     = "external-dns"
  external_dns_domain_filters = ["example.com"]
  external_dns_policy        = "sync"

  tags = {
    Environment = "production"
    Project     = "multi-cloud-platform"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `resource_group_name` | Name of the Azure resource group | `string` | n/a | yes |
| `cluster_name` | Name of the AKS cluster | `string` | n/a | yes |
| `dns_zone_name` | Azure DNS zone name | `string` | n/a | yes |
| `dns_zone_resource_group` | Resource group containing the DNS zone | `string` | n/a | yes |
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
| `enable_external_dns` | Enable external-dns | `bool` | `true` | no |
| `external_dns_chart_version` | Helm chart version for external-dns | `string` | `"1.14.3"` | no |
| `external_dns_namespace` | Kubernetes namespace for external-dns | `string` | `"external-dns"` | no |
| `external_dns_domain_filters` | List of domain filters for external-dns | `list(string)` | `[]` | no |
| `external_dns_policy` | DNS record management policy (sync or upsert-only) | `string` | `"sync"` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `nginx_ingress_ip` | The IP address of the NGINX ingress load balancer |
| `nginx_ingress_namespace` | Namespace where NGINX ingress is deployed |
| `cert_manager_namespace` | Namespace where cert-manager is deployed |
| `external_dns_namespace` | Namespace where external-dns is deployed |
| `cert_manager_cluster_issuer_name` | Name of the cert-manager ClusterIssuer |
