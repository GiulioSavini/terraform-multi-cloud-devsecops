output "ingress_namespaces" {
  description = "Namespaces the ingress stack occupies."
  value       = module.services.ingress_namespaces
}

output "service_namespaces" {
  description = "Namespaces the platform services occupy."
  value       = module.services.service_namespaces
}

output "compliance_evidence" {
  description = "Control evidence for the in-cluster layer."
  value       = module.services.compliance_evidence
}
