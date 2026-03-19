output "ingress_nginx_namespace" {
  value = helm_release.nginx_ingress.namespace
}
