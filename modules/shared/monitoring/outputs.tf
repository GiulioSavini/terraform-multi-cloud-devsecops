output "monitoring_namespace" {
  value = helm_release.kube_prometheus_stack.namespace
}
