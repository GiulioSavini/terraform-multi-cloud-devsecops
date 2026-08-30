variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "replicas" {
  description = "Linkerd control plane replicas."
  type        = number
  default     = 3

  validation {
    condition     = var.replicas >= 1
    error_message = "replicas must be at least 1."
  }
}

variable "enable_viz_prometheus" {
  description = <<-EOT
    Deploy the Prometheus bundled with linkerd-viz. Leave false when the
    observability context is present: two Prometheus instances scraping the
    same targets double the cost and disagree during incidents.
  EOT
  type        = bool
  default     = false
}
