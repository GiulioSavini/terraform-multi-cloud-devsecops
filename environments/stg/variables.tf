# ─── General ──────────────────────────────────────────────────
variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "devsecops"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project))
    error_message = "Project name must be 3-21 lowercase alphanumeric characters or hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  default     = "stg"

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}

# ─── AWS ──────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "eu-west-1"
}

variable "aws_eks_node_count" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.aws_eks_node_count >= 1 && var.aws_eks_node_count <= 20
    error_message = "EKS node count must be between 1 and 20."
  }
}

variable "aws_eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.large"
}

variable "aws_eks_node_max_count" {
  description = "Maximum number of EKS worker nodes for autoscaling"
  type        = number
  default     = 4
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.10.0.0/16"

  validation {
    condition     = can(cidrhost(var.aws_vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

# ─── Azure ────────────────────────────────────────────────────
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "westeurope"
}

variable "azure_aks_node_count" {
  description = "Desired number of AKS worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.azure_aks_node_count >= 1 && var.azure_aks_node_count <= 20
    error_message = "AKS node count must be between 1 and 20."
  }
}

variable "azure_aks_node_vm_size" {
  description = "VM size for AKS worker nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "azure_aks_node_max_count" {
  description = "Maximum number of AKS worker nodes for autoscaling"
  type        = number
  default     = 4
}

variable "azure_vnet_cidr" {
  description = "CIDR block for Azure VNet"
  type        = string
  default     = "10.11.0.0/16"

  validation {
    condition     = can(cidrhost(var.azure_vnet_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

# ─── GCP ──────────────────────────────────────────────────────
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for resource deployment"
  type        = string
  default     = "europe-west1"
}

variable "gcp_gke_node_count" {
  description = "Desired number of GKE worker nodes per zone"
  type        = number
  default     = 2

  validation {
    condition     = var.gcp_gke_node_count >= 1 && var.gcp_gke_node_count <= 20
    error_message = "GKE node count must be between 1 and 20."
  }
}

variable "gcp_gke_node_machine_type" {
  description = "Machine type for GKE worker nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "gcp_gke_node_max_count" {
  description = "Maximum number of GKE worker nodes for autoscaling"
  type        = number
  default     = 4
}

variable "gcp_vpc_cidr" {
  description = "Primary CIDR block for GCP VPC subnet"
  type        = string
  default     = "10.12.0.0/16"

  validation {
    condition     = can(cidrhost(var.gcp_vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

# ─── Shared Services ─────────────────────────────────────────
variable "vault_replicas" {
  description = "Number of Vault replicas"
  type        = number
  default     = 3
}

variable "monitoring_retention_days" {
  description = "Prometheus data retention in days"
  type        = number
  default     = 7
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Base domain name for DNS records"
  type        = string
  default     = "stg.example.com"
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt certificate notifications"
  type        = string
  default     = "devops@example.com"
}
