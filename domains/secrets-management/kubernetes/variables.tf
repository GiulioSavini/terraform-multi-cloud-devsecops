variable "namespace" {
  description = "Kubernetes namespace for Vault"
  type        = string
  default     = "vault"
}

variable "replicas" {
  description = "Number of Vault server replicas"
  type        = number
  default     = 3

  validation {
    condition     = contains([1, 3, 5], var.replicas)
    error_message = "Vault replicas must be 1, 3, or 5 for proper Raft consensus."
  }
}

variable "storage_size" {
  description = "Size of the persistent volume for Vault data"
  type        = string
  default     = "10Gi"
}

variable "storage_class" {
  description = "Storage class for Vault persistent volumes"
  type        = string
  default     = "gp2"
}

variable "tls_disable" {
  description = "Disable TLS for Vault listener (enable only in dev)"
  type        = bool
  default     = false
}
