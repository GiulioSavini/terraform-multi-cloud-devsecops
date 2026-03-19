output "monitoring_namespace" {
  description = "Kubernetes namespace where monitoring stack is deployed"
  value       = helm_release.kube_prometheus_stack.namespace
}

output "monitoring_release_name" {
  description = "Helm release name for the monitoring stack"
  value       = helm_release.kube_prometheus_stack.name
}

output "monitoring_version" {
  description = "Deployed kube-prometheus-stack chart version"
  value       = helm_release.kube_prometheus_stack.version
}
