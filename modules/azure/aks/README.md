# Azure AKS Module

Provisions an Azure Kubernetes Service (AKS) cluster with configurable node pools, Azure Active Directory RBAC integration for identity management, and Azure Key Vault CSI driver for secure secrets injection into pods.

## Usage

```hcl
module "aks" {
  source = "./modules/azure/aks"

  cluster_name        = "my-aks-cluster"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  kubernetes_version  = "1.28"
  dns_prefix          = "myaks"

  vnet_subnet_id = module.networking.aks_subnet_id

  default_node_pool = {
    name                = "system"
    vm_size             = "Standard_D4s_v3"
    min_count           = 2
    max_count           = 5
    os_disk_size_gb     = 100
    enable_auto_scaling = true
    availability_zones  = ["1", "2", "3"]
  }

  additional_node_pools = {
    compute = {
      vm_size             = "Standard_F8s_v2"
      min_count           = 0
      max_count           = 20
      os_disk_size_gb     = 200
      enable_auto_scaling = true
      availability_zones  = ["1", "2", "3"]
      node_labels = {
        "role" = "compute"
      }
      node_taints = ["dedicated=compute:NoSchedule"]
    }
  }

  # Azure AD RBAC
  enable_azure_ad_rbac    = true
  azure_ad_admin_group_ids = ["00000000-0000-0000-0000-000000000000"]
  enable_azure_rbac        = true

  # Key Vault CSI Driver
  enable_key_vault_csi_driver = true
  key_vault_id                = module.security.key_vault_id

  # Network profile
  network_plugin    = "azure"
  network_policy    = "calico"
  service_cidr      = "172.16.0.0/16"
  dns_service_ip    = "172.16.0.10"

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
| `cluster_name` | Name of the AKS cluster | `string` | n/a | yes |
| `resource_group_name` | Name of the resource group | `string` | n/a | yes |
| `location` | Azure region for the AKS cluster | `string` | n/a | yes |
| `kubernetes_version` | Kubernetes version for the cluster | `string` | `"1.28"` | no |
| `dns_prefix` | DNS prefix for the AKS cluster | `string` | n/a | yes |
| `vnet_subnet_id` | Subnet ID for the AKS cluster | `string` | n/a | yes |
| `default_node_pool` | Configuration for the default system node pool | `object` | n/a | yes |
| `additional_node_pools` | Map of additional node pool configurations | `map(object)` | `{}` | no |
| `enable_azure_ad_rbac` | Enable Azure AD RBAC integration | `bool` | `true` | no |
| `azure_ad_admin_group_ids` | List of Azure AD group object IDs for cluster admin | `list(string)` | `[]` | no |
| `enable_azure_rbac` | Enable Azure RBAC for Kubernetes authorization | `bool` | `true` | no |
| `enable_key_vault_csi_driver` | Enable Azure Key Vault CSI driver | `bool` | `true` | no |
| `key_vault_id` | ID of the Azure Key Vault | `string` | `""` | no |
| `network_plugin` | Kubernetes network plugin (azure or kubenet) | `string` | `"azure"` | no |
| `network_policy` | Kubernetes network policy provider (calico or azure) | `string` | `"calico"` | no |
| `service_cidr` | CIDR block for Kubernetes services | `string` | `"172.16.0.0/16"` | no |
| `dns_service_ip` | IP address for the Kubernetes DNS service | `string` | `"172.16.0.10"` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | The ID of the AKS cluster |
| `cluster_name` | The name of the AKS cluster |
| `cluster_fqdn` | The FQDN of the AKS cluster |
| `kube_config` | Kubernetes configuration for the cluster |
| `kubelet_identity` | The kubelet managed identity |
| `node_resource_group` | The auto-generated resource group for cluster nodes |
| `oidc_issuer_url` | The OIDC issuer URL for workload identity |
| `key_vault_secrets_provider_identity` | The identity of the Key Vault CSI driver |
