output "namespace" {
  description = "Namespace Vault occupies."
  value       = module.kubernetes.vault_namespace
}

output "release" {
  description = "Helm release name and chart version."
  value = {
    name    = module.kubernetes.vault_release_name
    version = module.kubernetes.vault_version
  }
}

output "tls_enabled" {
  description = "Whether the Vault listener terminates TLS. Evidence for ISO 27001 A.8.24 and SOC 2 CC6.7."
  value       = !var.tls_disable
}

output "ha_replicas" {
  description = "Raft voter count. Evidence for availability of the secret store."
  value       = var.replicas
}
