output "waf_acl_arn" {
  description = "ARN of the WAFv2 WebACL"
  value       = aws_wafv2_web_acl.this.arn
}

output "waf_acl_id" {
  description = "ID of the WAFv2 WebACL"
  value       = aws_wafv2_web_acl.this.id
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.this.id
}

output "config_recorder_id" {
  description = "ID of the AWS Config recorder"
  value       = aws_config_configuration_recorder.this.id
}

output "securityhub_account_id" {
  description = "SecurityHub account ID"
  value       = aws_securityhub_account.this.id
}
