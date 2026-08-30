variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
  default     = "europe-west1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,39}$", var.cluster_name))
    error_message = "Cluster name must be 3-40 lowercase alphanumeric characters or hyphens."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the GKE cluster"
  type        = string
  default     = "1.29"
}

variable "network" {
  description = "VPC network name for the cluster"
  type        = string
}

variable "subnetwork" {
  description = "VPC subnetwork name for the cluster"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary IP range for pods"
  type        = string
  default     = "pods"
}

variable "services_range_name" {
  description = "Name of the secondary IP range for services"
  type        = string
  default     = "services"
}

variable "regional" {
  description = "Whether to create a regional (multi-zone) cluster"
  type        = bool
  default     = true
}

variable "node_count" {
  description = "Initial number of nodes per zone"
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1
    error_message = "Node count must be at least 1."
  }
}

variable "node_min_count" {
  description = "Minimum number of nodes for autoscaling per zone"
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "node_max_count" {
  description = "Maximum number of nodes for autoscaling per zone"
  type        = number
  default     = 5

  validation {
    condition     = var.node_max_count >= 1
    error_message = "Maximum node count must be at least 1."
  }
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size_gb" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 50

  validation {
    condition     = var.node_disk_size_gb >= 20 && var.node_disk_size_gb <= 500
    error_message = "Disk size must be between 20 and 500 GB."
  }
}
