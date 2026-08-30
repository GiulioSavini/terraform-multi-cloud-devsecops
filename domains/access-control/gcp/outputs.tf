output "security_policy_id" {
  description = "ID of the Cloud Armor security policy"
  value       = google_compute_security_policy.this.id
}

output "security_policy_name" {
  description = "Name of the Cloud Armor security policy"
  value       = google_compute_security_policy.this.name
}

output "workload_sa_email" {
  description = "Email of the workload identity service account"
  value       = google_service_account.workload.email
}

output "scc_topic_id" {
  description = "ID of the Pub/Sub topic for SCC findings"
  value       = google_pubsub_topic.scc_findings.id
}
