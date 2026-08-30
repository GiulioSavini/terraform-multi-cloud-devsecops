variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "namespace" {
  description = "Namespace the monitoring stack runs in."
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Grafana admin password. Inject from a secret store; never commit it."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.grafana_admin_password) >= 16
    error_message = "grafana_admin_password must be at least 16 characters. Grafana is internet-adjacent through ingress and is routinely credential-stuffed."
  }
}

variable "retention_days" {
  description = "Metric retention in days."
  type        = number
  default     = 90

  validation {
    condition     = var.retention_days >= 15
    error_message = "retention_days must be at least 15. Shorter retention cannot show a month-over-month regression."
  }
}

variable "storage_class" {
  description = "Storage class for Prometheus volumes. Empty uses the cluster default."
  type        = string
  default     = ""
}
