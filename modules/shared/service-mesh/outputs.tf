output "linkerd_namespace" {
  value = helm_release.linkerd_control_plane.namespace
}

output "trust_anchor_cert" {
  value     = tls_self_signed_cert.trust_anchor.cert_pem
  sensitive = true
}
