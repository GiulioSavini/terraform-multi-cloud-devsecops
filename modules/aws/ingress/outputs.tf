output "lb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.lb_controller.arn
}

output "external_dns_role_arn" {
  description = "ARN of the IAM role for external-dns"
  value       = aws_iam_role.external_dns.arn
}

output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed"
  value       = helm_release.cert_manager.namespace
}
