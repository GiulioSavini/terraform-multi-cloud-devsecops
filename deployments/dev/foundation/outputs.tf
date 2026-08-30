output "cluster_names" {
  description = "Cluster names by cloud."
  value       = module.foundation.cluster_names
}

output "clusters" {
  description = "Cluster connection details, read by the services deployments."
  value       = module.foundation.clusters
  sensitive   = true
}

output "networks" {
  description = "Network fabric."
  value       = module.foundation.networks
}

output "aws_irsa" {
  description = "IRSA wiring."
  value       = module.foundation.aws_irsa
}

output "compliance_evidence" {
  description = "Control evidence for the cloud layer."
  value       = module.foundation.compliance_evidence
}
