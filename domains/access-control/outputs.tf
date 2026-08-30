output "edge_policy" {
  description = "Edge protection handles, for the traffic-ingress context to associate with a load balancer."
  value = merge(
    local.aws_enabled ? { aws = {
      waf_acl_arn = module.aws[0].waf_acl_arn
      waf_acl_id  = module.aws[0].waf_acl_id
    } } : {},
    local.gcp_enabled ? { gcp = {
      security_policy_id   = module.gcp[0].security_policy_id
      security_policy_name = module.gcp[0].security_policy_name
    } } : {},
  )
}

output "threat_detection" {
  description = "Threat detection services enabled per cloud. Evidence for CIS 3.x/4.x and SOC 2 CC7.2."
  value = merge(
    local.aws_enabled ? { aws = {
      guardduty_detector_id = module.aws[0].guardduty_detector_id
      securityhub_account   = module.aws[0].securityhub_account_id
      config_recorder_id    = module.aws[0].config_recorder_id
    } } : {},
    local.gcp_enabled ? { gcp = {
      scc_topic_id = module.gcp[0].scc_topic_id
    } } : {},
  )
}

output "secret_store" {
  description = "Cloud-managed secret store. Distinct from the in-cluster Vault owned by the secrets-management context."
  value = local.azure_enabled ? {
    azure = {
      key_vault_id   = module.azure[0].key_vault_id
      key_vault_uri  = module.azure[0].key_vault_uri
      key_vault_name = module.azure[0].key_vault_name
    }
  } : {}
}

output "workload_identity" {
  description = "Cloud identities workloads assume."
  value = local.gcp_enabled ? {
    gcp = { service_account_email = module.gcp[0].workload_sa_email }
  } : {}
}

output "waf_rate_limit" {
  description = "Effective WAF rate limit. Evidence for availability and abuse controls."
  value       = var.waf_rate_limit
}
