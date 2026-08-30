variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "namespace" {
  description = "Namespace Vault runs in."
  type        = string
  default     = "vault"
}

variable "replicas" {
  description = "Vault HA replicas. Raft consensus needs an odd number."
  type        = number
  default     = 3

  validation {
    condition     = var.replicas % 2 == 1
    error_message = "replicas must be odd. Raft cannot establish a quorum reliably with an even number of voters."
  }
}

variable "storage_size" {
  description = "Persistent volume size per Vault replica."
  type        = string
  default     = "10Gi"
}

variable "storage_class" {
  description = "Storage class for Vault's volumes. Empty uses the cluster default."
  type        = string
  default     = ""
}

variable "tls_disable" {
  description = "Disable TLS on the Vault listener. Only ever acceptable behind a service mesh that provides mTLS, and never in production."
  type        = bool
  default     = false
}
