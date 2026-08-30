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
  description = "Grafana admin password. Inject from a secret store; never commit it."
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "Azure subscription id."
  type        = string
  default     = ""
}

variable "azure_resource_group_name" {
  description = "Resource group holding the AKS cluster, from the foundation outputs."
  type        = string
}
