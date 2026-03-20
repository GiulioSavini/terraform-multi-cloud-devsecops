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

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,39}$", var.cluster_name))
    error_message = "Cluster name must be 3-40 lowercase alphanumeric characters or hyphens."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster and node groups"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets are required for EKS."
  }
}

variable "node_desired_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_count >= 1
    error_message = "Desired node count must be at least 1."
  }
}

variable "node_max_count" {
  description = "Maximum number of worker nodes for autoscaling"
  type        = number
  default     = 5

  validation {
    condition     = var.node_max_count >= 1
    error_message = "Maximum node count must be at least 1."
  }
}

variable "node_min_count" {
  description = "Minimum number of worker nodes for autoscaling"
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_capacity_type" {
  description = "Capacity type for node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Capacity type must be ON_DEMAND or SPOT."
  }
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50

  validation {
    condition     = var.node_disk_size >= 20 && var.node_disk_size <= 500
    error_message = "Disk size must be between 20 and 500 GB."
  }
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster API endpoint is publicly accessible"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
