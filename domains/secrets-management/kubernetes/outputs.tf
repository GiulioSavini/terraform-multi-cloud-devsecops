output "vault_namespace" {
  description = "Kubernetes namespace where Vault is deployed"
  value       = helm_release.vault.namespace
}

output "vault_release_name" {
  description = "Helm release name for Vault"
  value       = helm_release.vault.name
}

output "vault_version" {
  description = "Deployed Vault chart version"
  value       = helm_release.vault.version
}
