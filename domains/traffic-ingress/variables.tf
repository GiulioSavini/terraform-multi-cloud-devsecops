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

variable "cluster_names" {
  description = "The `cluster_names` output of the cluster-platform context."
  type        = map(string)
}

variable "aws_irsa" {
  description = "The `aws_irsa` output of the cluster-platform context. Required when aws is in scope."
  type        = any
  default     = null
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    aws = optional(object({ region = string }))
    gcp = optional(object({ project_id = string }))
  })
  default = {}
}

variable "domain_name" {
  description = "Domain ingress certificates are issued for."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.domain_name))
    error_message = "domain_name must be a valid lowercase DNS name."
  }
}

variable "letsencrypt_email" {
  description = "Contact address for the ACME account. Let's Encrypt sends expiry warnings here; an unmonitored address means certificates expire silently."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.letsencrypt_email))
    error_message = "letsencrypt_email must be a valid email address."
  }
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
  default     = {}
}
