# ─── AWS Outputs ──────────────────────────────────────────────
output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_networking.vpc_id
}

output "aws_eks_cluster_name" {
  description = "AWS EKS cluster name"
  value       = module.aws_eks.cluster_name
}

output "aws_eks_cluster_endpoint" {
  description = "AWS EKS cluster API endpoint"
  value       = module.aws_eks.cluster_endpoint
  sensitive   = true
}

output "aws_eks_kubeconfig_command" {
  description = "Command to configure kubectl for AWS EKS"
  value       = "aws eks update-kubeconfig --name ${module.aws_eks.cluster_name} --region ${var.aws_region}"
}

# ─── Azure Outputs ────────────────────────────────────────────
output "azure_resource_group" {
  description = "Azure resource group name"
  value       = module.azure_networking.resource_group_name
}

output "azure_aks_cluster_name" {
  description = "Azure AKS cluster name"
  value       = module.azure_aks.cluster_name
}

output "azure_aks_kubeconfig_command" {
  description = "Command to configure kubectl for Azure AKS"
  value       = "az aks get-credentials --resource-group ${module.azure_networking.resource_group_name} --name ${module.azure_aks.cluster_name}"
}

# ─── GCP Outputs ──────────────────────────────────────────────
output "gcp_gke_cluster_name" {
  description = "GCP GKE cluster name"
  value       = module.gcp_gke.cluster_name
}

output "gcp_gke_kubeconfig_command" {
  description = "Command to configure kubectl for GCP GKE"
  value       = "gcloud container clusters get-credentials ${module.gcp_gke.cluster_name} --region ${var.gcp_region}"
}

# ─── Shared Services Outputs ─────────────────────────────────
output "vault_ui_url" {
  description = "Vault UI URL (after port-forward)"
  value       = "http://localhost:8200 (kubectl port-forward svc/vault-ui 8200:8200 -n vault)"
}

output "grafana_url" {
  description = "Grafana URL (after port-forward)"
  value       = "http://localhost:3000 (kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring)"
}
