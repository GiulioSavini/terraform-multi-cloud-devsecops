# AWS Ingress Module

Deploys the AWS ALB Ingress Controller for Kubernetes ingress management, cert-manager for automated TLS certificate provisioning via Let's Encrypt, and external-dns for automatic DNS record management in Route 53.

## Usage

```hcl
module "ingress" {
  source = "./modules/aws/ingress"

  cluster_name             = module.eks.cluster_id
  cluster_endpoint         = module.eks.cluster_endpoint
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id                   = module.networking.vpc_id

  # ALB Controller
  enable_alb_controller        = true
  alb_controller_chart_version = "1.6.2"
  alb_controller_namespace     = "kube-system"

  # cert-manager
  enable_cert_manager        = true
  cert_manager_chart_version = "v1.13.3"
  cert_manager_namespace     = "cert-manager"
  cert_manager_email         = "admin@example.com"
  cert_manager_issuer_type   = "ClusterIssuer"
  cert_manager_solver        = "dns01"
  route53_zone_id            = "Z1234567890ABC"

  # external-dns
  enable_external_dns        = true
  external_dns_chart_version = "1.14.3"
  external_dns_namespace     = "external-dns"
  external_dns_domain_filters = ["example.com"]
  external_dns_zone_id       = "Z1234567890ABC"
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
| `cluster_name` | Name of the EKS cluster | `string` | n/a | yes |
| `cluster_endpoint` | Endpoint URL of the EKS cluster | `string` | n/a | yes |
| `cluster_oidc_provider_arn` | ARN of the OIDC provider for IRSA | `string` | n/a | yes |
| `vpc_id` | ID of the VPC | `string` | n/a | yes |
| `enable_alb_controller` | Enable the AWS ALB Ingress Controller | `bool` | `true` | no |
| `alb_controller_chart_version` | Helm chart version for ALB controller | `string` | `"1.6.2"` | no |
| `alb_controller_namespace` | Kubernetes namespace for ALB controller | `string` | `"kube-system"` | no |
| `enable_cert_manager` | Enable cert-manager | `bool` | `true` | no |
| `cert_manager_chart_version` | Helm chart version for cert-manager | `string` | `"v1.13.3"` | no |
| `cert_manager_namespace` | Kubernetes namespace for cert-manager | `string` | `"cert-manager"` | no |
| `cert_manager_email` | Email address for Let's Encrypt registration | `string` | n/a | yes |
| `cert_manager_issuer_type` | Type of cert-manager issuer (ClusterIssuer or Issuer) | `string` | `"ClusterIssuer"` | no |
| `cert_manager_solver` | ACME challenge solver type (dns01 or http01) | `string` | `"dns01"` | no |
| `route53_zone_id` | Route 53 hosted zone ID for DNS validation | `string` | `""` | no |
| `enable_external_dns` | Enable external-dns | `bool` | `true` | no |
| `external_dns_chart_version` | Helm chart version for external-dns | `string` | `"1.14.3"` | no |
| `external_dns_namespace` | Kubernetes namespace for external-dns | `string` | `"external-dns"` | no |
| `external_dns_domain_filters` | List of domain filters for external-dns | `list(string)` | `[]` | no |
| `external_dns_zone_id` | Route 53 zone ID for external-dns | `string` | `""` | no |
| `external_dns_policy` | DNS record management policy (sync or upsert-only) | `string` | `"sync"` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `alb_controller_iam_role_arn` | IAM role ARN for the ALB controller |
| `cert_manager_iam_role_arn` | IAM role ARN for cert-manager |
| `external_dns_iam_role_arn` | IAM role ARN for external-dns |
| `alb_controller_namespace` | Namespace where ALB controller is deployed |
| `cert_manager_namespace` | Namespace where cert-manager is deployed |
| `external_dns_namespace` | Namespace where external-dns is deployed |
