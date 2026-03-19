# GCP GKE Module

Provisions a private Google Kubernetes Engine (GKE) cluster with Workload Identity for secure pod-to-GCP-service authentication, Binary Authorization for container image verification, and configurable node pools with auto-scaling.

## Usage

```hcl
module "gke" {
  source = "./modules/gcp/gke"

  project_id   = "my-gcp-project"
  cluster_name = "my-gke-cluster"
  region       = "us-central1"
  zones        = ["us-central1-a", "us-central1-b", "us-central1-c"]

  network    = module.networking.vpc_name
  subnetwork = module.networking.subnet_name

  # Private cluster
  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = "172.16.0.0/28"
  master_authorized_networks = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "internal-network"
    }
  ]

  # Workload Identity
  enable_workload_identity = true
  workload_identity_config = "my-gcp-project.svc.id.goog"

  # Binary Authorization
  enable_binary_authorization = true
  binary_authorization_mode   = "PROJECT_SINGLETON_POLICY_ENFORCE"

  # Node pools
  node_pools = {
    general = {
      machine_type   = "e2-standard-4"
      min_count      = 2
      max_count      = 10
      disk_size_gb   = 100
      disk_type      = "pd-ssd"
      image_type     = "COS_CONTAINERD"
      auto_repair    = true
      auto_upgrade   = true
      preemptible    = false
      labels = {
        role = "general"
      }
    }
    compute = {
      machine_type   = "c2-standard-8"
      min_count      = 0
      max_count      = 20
      disk_size_gb   = 200
      disk_type      = "pd-ssd"
      image_type     = "COS_CONTAINERD"
      auto_repair    = true
      auto_upgrade   = true
      preemptible    = true
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

  # Cluster features
  enable_network_policy     = true
  enable_dataplane_v2       = true
  enable_shielded_nodes     = true
  release_channel           = "REGULAR"

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
| `region` | GCP region for the cluster | `string` | n/a | yes |
| `zones` | List of GCP zones for the node pools | `list(string)` | `[]` | no |
| `network` | Name of the VPC network | `string` | n/a | yes |
| `subnetwork` | Name of the VPC subnetwork | `string` | n/a | yes |
| `enable_private_nodes` | Enable private nodes (no external IP) | `bool` | `true` | no |
| `enable_private_endpoint` | Enable private endpoint (no public IP for master) | `bool` | `false` | no |
| `master_ipv4_cidr_block` | CIDR block for the GKE master network | `string` | `"172.16.0.0/28"` | no |
| `master_authorized_networks` | List of authorized networks for master access | `list(object)` | `[]` | no |
| `enable_workload_identity` | Enable Workload Identity | `bool` | `true` | no |
| `workload_identity_config` | Workload Identity pool configuration | `string` | `""` | no |
| `enable_binary_authorization` | Enable Binary Authorization | `bool` | `true` | no |
| `binary_authorization_mode` | Binary Authorization evaluation mode | `string` | `"PROJECT_SINGLETON_POLICY_ENFORCE"` | no |
| `node_pools` | Map of node pool configurations | `map(object)` | `{}` | no |
| `enable_network_policy` | Enable Kubernetes NetworkPolicy | `bool` | `true` | no |
| `enable_dataplane_v2` | Enable GKE Dataplane V2 (Cilium) | `bool` | `true` | no |
| `enable_shielded_nodes` | Enable shielded GKE nodes | `bool` | `true` | no |
| `release_channel` | Release channel for GKE upgrades (RAPID, REGULAR, STABLE) | `string` | `"REGULAR"` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | The ID of the GKE cluster |
| `cluster_name` | The name of the GKE cluster |
| `cluster_endpoint` | The endpoint of the GKE cluster |
| `cluster_ca_certificate` | Base64 encoded CA certificate for cluster authentication |
| `cluster_master_version` | The current master version of the GKE cluster |
| `workload_identity_pool` | The Workload Identity pool for the cluster |
| `node_pool_names` | List of node pool names |
| `service_account_email` | The default service account email for the cluster |
