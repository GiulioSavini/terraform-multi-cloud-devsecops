variable "landing_zone" {
  description = "Platform identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "cloud" {
  description = <<-EOT
    The single cloud whose cluster this deployment targets. One deployment per
    cluster: the kubernetes and helm providers each address exactly one API
    server, and there is no way to fan one root out across three clusters
    without provider aliases every module would have to accept.
  EOT
  type        = string

  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud)
    error_message = "cloud must be one of: aws, azure, gcp."
  }
}

variable "cluster_name" {
  description = "Name of the target cluster, from the cloud-foundation outputs."
  type        = string
}

variable "networks" {
  description = "The `networks` output of cloud-foundation."
  type        = any
}

variable "aws_irsa" {
  description = "The `aws_irsa` output of cloud-foundation. Required when cloud is aws."
  type        = any
  default     = null
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "gcp_project_id" {
  description = "GCP project id."
  type        = string
  default     = ""
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

variable "domain_name" {
  description = "Domain ingress certificates are issued for."
  type        = string
}

variable "letsencrypt_email" {
  description = "Contact address for the ACME account."
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password. Inject from a secret store."
  type        = string
  sensitive   = true
}

variable "vault_replicas" {
  description = "Vault Raft voters. Must be odd."
  type        = number
  default     = 3
}

variable "gatekeeper_replicas" {
  description = "Gatekeeper admission controller replicas."
  type        = number
  default     = 3
}

variable "mesh_replicas" {
  description = "Linkerd control plane replicas."
  type        = number
  default     = 3
}

variable "metrics_retention_days" {
  description = "In-cluster metric retention."
  type        = number
  default     = 90
}

variable "metrics_storage_class" {
  description = "Storage class for Prometheus volumes. Required in prd."
  type        = string
  default     = ""
}

variable "vault_storage_class" {
  description = "Storage class for Vault volumes."
  type        = string
  default     = ""
}
