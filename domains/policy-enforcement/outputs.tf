output "namespace" {
  description = "Namespace Gatekeeper occupies."
  value       = module.kubernetes.gatekeeper_namespace
}

output "release" {
  description = "Helm release name and chart version. Evidence for change management controls."
  value = {
    name    = module.kubernetes.gatekeeper_release_name
    version = module.kubernetes.gatekeeper_version
  }
}

output "replicas" {
  description = "Admission controller replicas. Evidence for availability of the enforcement path."
  value       = var.replicas
}
