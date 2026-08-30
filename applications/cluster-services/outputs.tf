output "ingress_namespaces" {
  description = "Namespaces the ingress stack occupies."
  value       = module.traffic_ingress.namespaces
}

output "service_namespaces" {
  description = "Namespaces the platform services occupy."
  value = {
    policy_enforcement = module.policy_enforcement.namespace
    secrets_management = module.secrets_management.namespace
    observability      = module.observability.namespace
    service_mesh       = module.service_mesh.namespaces
  }
}

output "compliance_evidence" {
  description = "Control evidence read from the context contracts."
  value = {
    "ING-01" = module.traffic_ingress.domain_name
    "POL-01" = module.policy_enforcement.replicas
    "VLT-01" = module.secrets_management.tls_enabled
    "MSH-01" = module.service_mesh.mtls_enabled
    "OBS-01" = module.observability.retention_days
  }
}
