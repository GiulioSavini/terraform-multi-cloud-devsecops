variable "landing_zone" {
  description = "Platform identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds in scope."
  type        = list(string)
}

variable "networks" {
  description = "The `networks` output of the networking context."
  type        = any
}

variable "gcp_cluster_ranges" {
  description = "The `gcp_cluster_ranges` output of the networking context. Required when gcp is in scope."
  type        = any
  default     = null
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    azure = optional(object({
      location            = string
      resource_group_name = string
    }))
    gcp = optional(object({ region = string }))
  })
  default = {}
}

variable "kubernetes_version" {
  description = <<-EOT
    Kubernetes minor version, e.g. "1.30". Pinned rather than defaulted to
    latest: an unpinned control plane upgrades underneath the workloads and
    silently invalidates whatever the last conformance test proved.
  EOT
  type        = string

  validation {
    condition     = can(regex("^1\\.(2[89]|3[0-9])$", var.kubernetes_version))
    error_message = "kubernetes_version must be a supported 1.28-1.39 minor version, e.g. \"1.30\"."
  }
}

variable "node_capacity" {
  description = "Worker node count, expressed once for every cloud."
  type = object({
    min     = number
    desired = number
    max     = number
  })
  default = {
    min     = 2
    desired = 3
    max     = 10
  }

  validation {
    condition     = var.node_capacity.min <= var.node_capacity.desired && var.node_capacity.desired <= var.node_capacity.max
    error_message = "node_capacity must satisfy min <= desired <= max."
  }

  validation {
    condition     = var.node_capacity.min >= 2
    error_message = "node_capacity.min must be at least 2. A single node cannot drain for an upgrade without downtime."
  }
}

variable "node_size" {
  description = "Worker machine size per cloud. Provider-specific by nature."
  type = object({
    aws   = optional(string, "t3.large")
    azure = optional(string, "Standard_D2s_v3")
    gcp   = optional(string, "e2-standard-2")
  })
  default = {}
}

variable "endpoint_public_access" {
  description = <<-EOT
    Expose the Kubernetes API server to the internet. Enabled by default only
    because a private endpoint requires a bastion or VPN this platform does not
    provision; policy CLU-01 asserts it is disabled in prd.
  EOT
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Control plane log retention."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 90
    error_message = "log_retention_days must be at least 90."
  }
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}
