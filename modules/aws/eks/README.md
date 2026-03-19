# AWS EKS Module

Provisions an Amazon EKS cluster with managed node groups, OIDC provider for IAM Roles for Service Accounts (IRSA), and configurable EKS addons (CoreDNS, kube-proxy, vpc-cni, ebs-csi-driver).

## Usage

```hcl
module "eks" {
  source = "./modules/aws/eks"

  cluster_name    = "my-cluster"
  cluster_version = "1.28"
  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.private_subnet_ids

  enable_oidc_provider = true

  managed_node_groups = {
    general = {
      instance_types = ["m5.xlarge"]
      min_size       = 2
      max_size       = 10
      desired_size   = 3
      disk_size      = 50
      labels = {
        role = "general"
      }
    }
    compute = {
      instance_types = ["c5.2xlarge"]
      min_size       = 0
      max_size       = 20
      desired_size   = 0
      disk_size      = 100
      labels = {
        role = "compute"
      }
      taints = [{
        key    = "dedicated"
        value  = "compute"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  cluster_addons = {
    coredns    = { version = "v1.10.1-eksbuild.6" }
    kube-proxy = { version = "v1.28.4-eksbuild.1" }
    vpc-cni    = { version = "v1.16.0-eksbuild.1" }
    aws-ebs-csi-driver = {
      version                  = "v1.27.0-eksbuild.1"
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

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
| `cluster_version` | Kubernetes version for the EKS cluster | `string` | `"1.28"` | no |
| `vpc_id` | ID of the VPC where the cluster will be deployed | `string` | n/a | yes |
| `subnet_ids` | List of subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| `enable_oidc_provider` | Enable OIDC provider for IRSA | `bool` | `true` | no |
| `managed_node_groups` | Map of managed node group configurations | `map(object)` | `{}` | no |
| `cluster_addons` | Map of EKS addon configurations | `map(object)` | `{}` | no |
| `cluster_endpoint_public_access` | Enable public access to the cluster API endpoint | `bool` | `false` | no |
| `cluster_endpoint_private_access` | Enable private access to the cluster API endpoint | `bool` | `true` | no |
| `cluster_log_types` | List of control plane logging types to enable | `list(string)` | `["api", "audit", "authenticator"]` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | The ID of the EKS cluster |
| `cluster_arn` | The ARN of the EKS cluster |
| `cluster_endpoint` | The endpoint URL of the EKS cluster API server |
| `cluster_certificate_authority_data` | Base64 encoded certificate data for cluster authentication |
| `cluster_security_group_id` | Security group ID attached to the EKS cluster |
| `oidc_provider_arn` | ARN of the OIDC provider for IRSA |
| `oidc_provider_url` | URL of the OIDC provider |
| `node_group_arns` | Map of node group names to their ARNs |
| `cluster_primary_security_group_id` | The cluster primary security group ID |
