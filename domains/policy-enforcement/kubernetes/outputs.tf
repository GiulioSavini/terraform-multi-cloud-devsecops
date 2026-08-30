output "gatekeeper_namespace" {
  description = "Kubernetes namespace where Gatekeeper is deployed"
  value       = helm_release.gatekeeper.namespace
}

output "gatekeeper_release_name" {
  description = "Helm release name for Gatekeeper"
  value       = helm_release.gatekeeper.name
}

output "gatekeeper_version" {
  description = "Deployed Gatekeeper chart version"
  value       = helm_release.gatekeeper.version
}
