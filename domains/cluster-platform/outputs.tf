# ------------------------------------------------------------------------------
# Published contract of the cluster-platform context.
#
# This is the seam of the platform: every in-cluster context consumes `clusters`
# and none of them knows whether it is talking to EKS, AKS or GKE.
# ------------------------------------------------------------------------------

output "clusters" {
  description = "Uniform per-cloud cluster handle: name, endpoint, CA certificate and OIDC issuer."
  value = merge(
    local.aws_enabled ? { aws = {
      name           = module.aws[0].cluster_name
      endpoint       = module.aws[0].cluster_endpoint
      ca_certificate = module.aws[0].cluster_ca_certificate
      oidc_issuer    = module.aws[0].oidc_issuer_url
      version        = module.aws[0].cluster_version
    } } : {},
    local.azure_enabled ? { azure = {
      name           = module.azure[0].cluster_name
      endpoint       = module.azure[0].kube_config_host
      ca_certificate = module.azure[0].kube_config_ca_certificate
      oidc_issuer    = module.azure[0].oidc_issuer_url
      version        = var.kubernetes_version
    } } : {},
    local.gcp_enabled ? { gcp = {
      name           = module.gcp[0].cluster_name
      endpoint       = module.gcp[0].cluster_endpoint
      ca_certificate = module.gcp[0].cluster_ca_certificate
      oidc_issuer    = null
      version        = var.kubernetes_version
    } } : {},
  )
  sensitive = true
}

output "cluster_names" {
  description = "Cluster names by cloud. Non-sensitive, so it can be printed and logged."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].cluster_name } : {},
    local.azure_enabled ? { azure = module.azure[0].cluster_name } : {},
    local.gcp_enabled ? { gcp = module.gcp[0].cluster_name } : {},
  )
}

output "aws_irsa" {
  description = "IAM Roles for Service Accounts wiring. AWS-specific: the other providers bind identity differently."
  value = local.aws_enabled ? {
    oidc_issuer_url     = module.aws[0].oidc_issuer_url
    oidc_provider_arn   = module.aws[0].oidc_provider_arn
    node_group_role_arn = module.aws[0].node_group_role_arn
  } : null
}

output "endpoint_public_access" {
  description = "Whether the API server is internet-reachable. Evidence for CIS Kubernetes 5.x and ISO 27001 A.8.20."
  value       = var.endpoint_public_access
}

output "kubernetes_version" {
  description = "Pinned control plane version. Evidence for vulnerability management controls."
  value       = var.kubernetes_version
}
