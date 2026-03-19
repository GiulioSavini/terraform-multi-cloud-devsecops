# Shared Vault Module

Deploys HashiCorp Vault in high-availability (HA) mode using the integrated Raft storage backend. This module provisions Vault via the official Helm chart with production-grade settings including auto-unseal, audit logging, and TLS configuration.

## Usage

```hcl
module "vault" {
  source = "./modules/shared/vault"

  namespace        = "vault"
  create_namespace = true

  helm_chart_version = "0.27.0"

  replicas = 3

  # Raft storage
  storage_size       = "50Gi"
  storage_class_name = "gp3"

  # HA configuration
  ha_enabled = true
  raft_config = {
    retry_join_interval = "5s"
    max_entry_size      = "1048576"
  }

  # Auto-unseal (AWS KMS example)
  auto_unseal_enabled = true
  auto_unseal_type    = "awskms"
  auto_unseal_config = {
    region     = "us-east-1"
    kms_key_id = "alias/vault-unseal-key"
  }

  # TLS
  tls_enabled     = true
  tls_secret_name = "vault-tls"

  # Audit logging
  enable_audit_log     = true
  audit_log_path       = "/vault/audit/vault-audit.log"
  audit_log_storage    = "10Gi"

  # Ingress
  ingress_enabled    = true
  ingress_host       = "vault.example.com"
  ingress_class_name = "nginx"
  ingress_tls        = true

  # Resource limits
  resources = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "2000m"
      memory = "4Gi"
    }
  }

  # Service account for cloud provider integration
  service_account_annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::123456789012:role/vault-role"
  }

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
| `namespace` | Kubernetes namespace for Vault | `string` | `"vault"` | no |
| `create_namespace` | Create the namespace if it does not exist | `bool` | `true` | no |
| `helm_chart_version` | Helm chart version for Vault | `string` | `"0.27.0"` | no |
| `replicas` | Number of Vault server replicas | `number` | `3` | no |
| `storage_size` | Storage size for Raft persistent volumes | `string` | `"50Gi"` | no |
| `storage_class_name` | Storage class for Raft persistent volumes | `string` | `""` | no |
| `ha_enabled` | Enable HA mode | `bool` | `true` | no |
| `raft_config` | Raft storage configuration parameters | `map(string)` | `{}` | no |
| `auto_unseal_enabled` | Enable auto-unseal | `bool` | `false` | no |
| `auto_unseal_type` | Auto-unseal provider type (awskms, azurekeyvault, gcpckms) | `string` | `""` | no |
| `auto_unseal_config` | Auto-unseal provider configuration | `map(string)` | `{}` | no |
| `tls_enabled` | Enable TLS for Vault | `bool` | `true` | no |
| `tls_secret_name` | Kubernetes secret name containing TLS certificates | `string` | `""` | no |
| `enable_audit_log` | Enable audit logging | `bool` | `true` | no |
| `audit_log_path` | Path for audit log files | `string` | `"/vault/audit/vault-audit.log"` | no |
| `audit_log_storage` | Storage size for audit logs | `string` | `"10Gi"` | no |
| `ingress_enabled` | Enable ingress for Vault UI | `bool` | `false` | no |
| `ingress_host` | Hostname for Vault ingress | `string` | `""` | no |
| `ingress_class_name` | Ingress class name | `string` | `"nginx"` | no |
| `ingress_tls` | Enable TLS on ingress | `bool` | `true` | no |
| `resources` | CPU and memory resource requests and limits | `object` | `{}` | no |
| `service_account_annotations` | Annotations for the Vault service account | `map(string)` | `{}` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vault_namespace` | The namespace where Vault is deployed |
| `vault_service_name` | The Kubernetes service name for Vault |
| `vault_internal_url` | The internal URL for Vault |
| `vault_ingress_url` | The external URL for Vault (if ingress is enabled) |
| `vault_service_account` | The Vault service account name |
