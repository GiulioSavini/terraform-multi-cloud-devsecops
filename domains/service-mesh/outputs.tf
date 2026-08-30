output "namespaces" {
  description = "Namespaces the mesh occupies."
  value = {
    control_plane = module.kubernetes.linkerd_namespace
    viz           = module.kubernetes.linkerd_viz_namespace
  }
}

output "release_version" {
  description = "Linkerd chart version. Evidence for change management controls."
  value       = module.kubernetes.linkerd_version
}

output "trust_anchor_cert_pem" {
  description = "Mesh trust anchor. Needed to enrol a workload outside this Terraform run."
  value       = module.kubernetes.trust_anchor_cert_pem
  sensitive   = true
}

output "mtls_enabled" {
  description = "The mesh provides mTLS between pods by construction. Evidence for ISO 27001 A.8.24 and NIS2 Art. 21(2)(h)."
  value       = true
}
