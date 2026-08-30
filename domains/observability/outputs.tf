output "namespace" {
  description = "Namespace the monitoring stack occupies."
  value       = module.kubernetes.monitoring_namespace
}

output "release" {
  description = "Helm release name and chart version."
  value = {
    name    = module.kubernetes.monitoring_release_name
    version = module.kubernetes.monitoring_version
  }
}

output "retention_days" {
  description = "Metric retention. Evidence for ISO 27001 A.8.16 and SOC 2 CC7.2."
  value       = var.retention_days
}
