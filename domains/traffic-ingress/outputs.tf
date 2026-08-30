output "namespaces" {
  description = "Namespaces the ingress stack occupies per cloud."
  value = merge(
    local.aws_enabled ? { aws = { cert_manager = module.aws[0].cert_manager_namespace } } : {},
    local.azure_enabled ? { azure = {
      ingress_nginx = module.azure[0].ingress_nginx_namespace
      cert_manager  = module.azure[0].cert_manager_namespace
      external_dns  = module.azure[0].external_dns_namespace
    } } : {},
    local.gcp_enabled ? { gcp = {
      ingress_nginx = module.gcp[0].ingress_nginx_namespace
      cert_manager  = module.gcp[0].cert_manager_namespace
      external_dns  = module.gcp[0].external_dns_namespace
    } } : {},
  )
}

output "aws_controller_roles" {
  description = "IRSA role ARNs the AWS ingress controllers assume."
  value = local.aws_enabled ? {
    load_balancer_controller = module.aws[0].lb_controller_role_arn
    external_dns             = module.aws[0].external_dns_role_arn
  } : null
}

output "domain_name" {
  description = "Domain certificates are issued for. Evidence for encryption-in-transit controls."
  value       = var.domain_name
}
