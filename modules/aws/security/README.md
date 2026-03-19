# AWS Security Module

Provisions a comprehensive AWS security stack including WAFv2 web ACLs for application protection, GuardDuty for threat detection, AWS Config for compliance monitoring, and SecurityHub for centralized security findings aggregation.

## Usage

```hcl
module "security" {
  source = "./modules/aws/security"

  environment = "production"

  # WAFv2 Configuration
  enable_waf = true
  waf_name   = "production-waf"
  waf_scope  = "REGIONAL"
  waf_rules = {
    rate_limit = {
      priority = 1
      action   = "block"
      rate_limit = 2000
    }
    aws_managed_common = {
      priority    = 2
      managed_rule_group = "AWSManagedRulesCommonRuleSet"
      vendor      = "AWS"
    }
    aws_managed_sql = {
      priority    = 3
      managed_rule_group = "AWSManagedRulesSQLiRuleSet"
      vendor      = "AWS"
    }
  }

  # GuardDuty Configuration
  enable_guardduty                  = true
  guardduty_s3_protection           = true
  guardduty_kubernetes_protection   = true
  guardduty_malware_protection      = true

  # AWS Config Configuration
  enable_aws_config         = true
  config_delivery_bucket    = "my-config-bucket"
  config_rules = [
    "encrypted-volumes",
    "root-account-mfa-enabled",
    "s3-bucket-ssl-requests-only",
    "vpc-flow-logs-enabled"
  ]

  # SecurityHub Configuration
  enable_security_hub   = true
  security_hub_standards = [
    "aws-foundational-security-best-practices/v/1.0.0",
    "cis-aws-foundations-benchmark/v/1.4.0"
  ]

  tags = {
    Environment = "production"
    Project     = "multi-cloud-platform"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `environment` | Environment name | `string` | n/a | yes |
| `enable_waf` | Enable WAFv2 web ACL | `bool` | `true` | no |
| `waf_name` | Name of the WAFv2 web ACL | `string` | `"default-waf"` | no |
| `waf_scope` | Scope of the WAF (REGIONAL or CLOUDFRONT) | `string` | `"REGIONAL"` | no |
| `waf_rules` | Map of WAF rule configurations | `map(object)` | `{}` | no |
| `enable_guardduty` | Enable Amazon GuardDuty | `bool` | `true` | no |
| `guardduty_s3_protection` | Enable S3 protection in GuardDuty | `bool` | `true` | no |
| `guardduty_kubernetes_protection` | Enable Kubernetes audit log monitoring in GuardDuty | `bool` | `true` | no |
| `guardduty_malware_protection` | Enable malware protection in GuardDuty | `bool` | `true` | no |
| `enable_aws_config` | Enable AWS Config | `bool` | `true` | no |
| `config_delivery_bucket` | S3 bucket name for AWS Config delivery | `string` | `""` | no |
| `config_rules` | List of AWS Config managed rule identifiers to enable | `list(string)` | `[]` | no |
| `enable_security_hub` | Enable AWS SecurityHub | `bool` | `true` | no |
| `security_hub_standards` | List of SecurityHub standards to enable | `list(string)` | `[]` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `waf_acl_arn` | ARN of the WAFv2 web ACL |
| `waf_acl_id` | ID of the WAFv2 web ACL |
| `guardduty_detector_id` | ID of the GuardDuty detector |
| `config_recorder_id` | ID of the AWS Config recorder |
| `security_hub_arn` | ARN of the SecurityHub hub |
