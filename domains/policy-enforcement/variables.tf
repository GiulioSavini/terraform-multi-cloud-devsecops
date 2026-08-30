variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "namespace" {
  description = "Namespace Gatekeeper runs in."
  type        = string
  default     = "gatekeeper-system"
}

variable "replicas" {
  description = "Gatekeeper controller replicas."
  type        = number
  default     = 3

  validation {
    condition     = var.replicas >= 1
    error_message = "replicas must be at least 1."
  }
}
