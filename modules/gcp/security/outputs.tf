output "security_policy_id" { value = google_compute_security_policy.main.id }
output "workload_sa_email" { value = google_service_account.workload.email }
output "scc_topic_id" { value = google_pubsub_topic.scc_findings.id }
