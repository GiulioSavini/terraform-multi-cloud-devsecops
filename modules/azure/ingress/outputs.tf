output "ingress_nginx_namespace" {
  description = "Namespace where NGINX Ingress Controller is installed"
  value       = helm_release.nginx_ingress.namespace
}

output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed"
  value       = helm_release.cert_manager.namespace
}

output "external_dns_namespace" {
  description = "Namespace where external-dns is installed"
  value       = helm_release.external_dns.namespace
}
