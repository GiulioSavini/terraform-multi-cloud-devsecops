variable "namespace" {
  description = "Kubernetes namespace for OPA Gatekeeper"
  type        = string
  default     = "gatekeeper-system"
}

variable "replicas" {
  description = "Number of Gatekeeper controller replicas"
  type        = number
  default     = 1

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 5
    error_message = "Replicas must be between 1 and 5."
  }
}
