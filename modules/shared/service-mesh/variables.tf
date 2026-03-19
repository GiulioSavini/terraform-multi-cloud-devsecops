variable "replicas" {
  description = "Number of control plane replicas"
  type        = number
  default     = 1

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 5
    error_message = "Replicas must be between 1 and 5."
  }
}

variable "enable_viz_prometheus" {
  description = "Enable Prometheus in Linkerd Viz (disable if using external Prometheus)"
  type        = bool
  default     = false
}
