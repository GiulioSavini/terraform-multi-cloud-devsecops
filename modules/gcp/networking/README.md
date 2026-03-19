# GCP Networking Module

Provisions a Google Cloud VPC network with configurable subnets, secondary IP ranges for GKE pods and services, and Cloud NAT for outbound internet access from private instances.

## Usage

```hcl
module "networking" {
  source = "./modules/gcp/networking"

  project_id = "my-gcp-project"
  region     = "us-central1"

  vpc_name                        = "production-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true

  subnets = {
    gke = {
      name          = "gke-subnet"
      ip_cidr_range = "10.0.0.0/20"
      region        = "us-central1"
      secondary_ip_ranges = {
        pods = {
          range_name    = "gke-pods"
          ip_cidr_range = "10.4.0.0/14"
        }
        services = {
          range_name    = "gke-services"
          ip_cidr_range = "10.8.0.0/20"
        }
      }
      private_google_access = true
    }
    bastion = {
      name          = "bastion-subnet"
      ip_cidr_range = "10.1.0.0/24"
      region        = "us-central1"
      private_google_access = true
    }
  }

  # Cloud NAT
  enable_cloud_nat  = true
  cloud_nat_name    = "production-nat"
  cloud_router_name = "production-router"
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Firewall rules
  firewall_rules = {
    allow-internal = {
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.0.0.0/8"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    }
    allow-health-checks = {
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
      allow = [{
        protocol = "tcp"
        ports    = ["80", "443"]
      }]
    }
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
| `project_id` | GCP project ID | `string` | n/a | yes |
| `region` | GCP region | `string` | n/a | yes |
| `vpc_name` | Name of the VPC network | `string` | n/a | yes |
| `auto_create_subnetworks` | Automatically create subnetworks | `bool` | `false` | no |
| `routing_mode` | Network routing mode (GLOBAL or REGIONAL) | `string` | `"GLOBAL"` | no |
| `delete_default_routes_on_create` | Delete default routes on VPC creation | `bool` | `true` | no |
| `subnets` | Map of subnet configurations | `map(object)` | `{}` | no |
| `enable_cloud_nat` | Enable Cloud NAT | `bool` | `true` | no |
| `cloud_nat_name` | Name of the Cloud NAT | `string` | `""` | no |
| `cloud_router_name` | Name of the Cloud Router | `string` | `""` | no |
| `nat_ip_allocate_option` | NAT IP allocation option (AUTO_ONLY or MANUAL_ONLY) | `string` | `"AUTO_ONLY"` | no |
| `source_subnetwork_ip_ranges_to_nat` | Source subnetwork IP ranges to NAT | `string` | `"ALL_SUBNETWORKS_ALL_IP_RANGES"` | no |
| `firewall_rules` | Map of firewall rule configurations | `map(object)` | `{}` | no |
| `labels` | Labels to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC network |
| `vpc_name` | The name of the VPC network |
| `vpc_self_link` | The self link of the VPC network |
| `subnet_ids` | Map of subnet names to their IDs |
| `subnet_name` | The name of the primary GKE subnet |
| `subnet_self_links` | Map of subnet names to their self links |
| `cloud_nat_name` | The name of the Cloud NAT |
| `cloud_router_name` | The name of the Cloud Router |
