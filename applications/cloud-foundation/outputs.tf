output "networks" {
  description = "Network fabric."
  value       = module.networking.networks
}

output "cluster_names" {
  description = "Cluster names by cloud. Consumed by the cluster-services application."
  value       = module.cluster_platform.cluster_names
}

output "clusters" {
  description = "Cluster connection details. Consumed by the cluster-services application through remote state."
  value       = module.cluster_platform.clusters
  sensitive   = true
}

output "aws_irsa" {
  description = "IRSA wiring for the AWS ingress controllers."
  value       = module.cluster_platform.aws_irsa
}

output "edge_policy" {
  description = "WAF and Cloud Armor handles."
  value       = module.access_control.edge_policy
}

output "compliance_evidence" {
  description = "Control evidence read from the context contracts."
  value = {
    "NET-01" = module.networking.networks
    "NET-02" = module.networking.egress_addresses
    "SEC-01" = module.access_control.threat_detection
    "SEC-02" = module.access_control.waf_rate_limit
    "CLU-01" = module.cluster_platform.endpoint_public_access
    "CLU-02" = module.cluster_platform.kubernetes_version
  }
}

output "control_catalog" {
  description = "Controls this platform claims, grouped by framework."
  value       = module.controls.by_framework
}
