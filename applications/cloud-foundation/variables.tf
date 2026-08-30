variable "landing_zone" {
  description = "Platform identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds this platform spans."
  type        = list(string)
}

variable "owner" {
  description = "Team accountable for this platform."
  type        = string
}

variable "cost_center" {
  description = "Cost center billed for this platform."
  type        = string
}

variable "data_classification" {
  description = "Highest classification of data the platform may hold."
  type        = string
}

variable "address_space" {
  description = "Non-overlapping CIDR per cloud."
  type = object({
    aws   = optional(string, "10.0.0.0/16")
    azure = optional(string, "10.1.0.0/16")
    gcp   = optional(string, "10.2.0.0/16")
  })
  default = {}
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "azure_location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "gcp_project_id" {
  description = "GCP project id."
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "europe-west1"
}

variable "kubernetes_version" {
  description = "Pinned Kubernetes minor version, e.g. \"1.30\"."
  type        = string
}

variable "node_capacity" {
  description = "Worker node count for every cluster."
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
}

variable "endpoint_public_access" {
  description = "Expose the Kubernetes API server to the internet. Must be false in prd."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Azure workspace security diagnostics are sent to."
  type        = string
  default     = ""
}

variable "waf_rate_limit" {
  description = "Requests per five minutes per source IP before the WAF blocks."
  type        = number
  default     = 2000
}

variable "log_retention_days" {
  description = "Control plane log retention."
  type        = number
  default     = 365
}
