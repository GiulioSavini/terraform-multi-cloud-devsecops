output "linkerd_namespace" {
  description = "Kubernetes namespace where Linkerd is deployed"
  value       = helm_release.linkerd_control_plane.namespace
}

output "linkerd_viz_namespace" {
  description = "Kubernetes namespace where Linkerd Viz is deployed"
  value       = helm_release.linkerd_viz.namespace
}

output "trust_anchor_cert_pem" {
  description = "PEM-encoded trust anchor certificate"
  value       = tls_self_signed_cert.trust_anchor.cert_pem
  sensitive   = true
}

output "linkerd_version" {
  description = "Deployed Linkerd control plane chart version"
  value       = helm_release.linkerd_control_plane.version
}
