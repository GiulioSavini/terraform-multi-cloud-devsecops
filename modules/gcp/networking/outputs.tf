output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.this.name
}

output "subnet_id" {
  description = "ID of the GKE subnet"
  value       = google_compute_subnetwork.gke.id
}

output "subnet_name" {
  description = "Name of the GKE subnet"
  value       = google_compute_subnetwork.gke.name
}

output "subnet_self_link" {
  description = "Self-link of the GKE subnet"
  value       = google_compute_subnetwork.gke.self_link
}

output "pods_range_name" {
  description = "Name of the secondary range for pods"
  value       = "pods"
}

output "services_range_name" {
  description = "Name of the secondary range for services"
  value       = "services"
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.this.name
}
