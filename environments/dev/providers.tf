terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.95"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

# ─── AWS Provider ─────────────────────────────────────────────
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# ─── Azure Provider ───────────────────────────────────────────
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.azure_subscription_id
}

# ─── GCP Provider ────────────────────────────────────────────
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ─── Kubernetes Provider (AWS EKS) ───────────────────────────
provider "kubernetes" {
  alias = "eks"

  host                   = module.aws_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.aws_eks.cluster_name]
  }
}

# ─── Helm Provider (AWS EKS) ─────────────────────────────────
provider "helm" {
  alias = "eks"

  kubernetes {
    host                   = module.aws_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.aws_eks.cluster_name]
    }
  }
}

# ─── Kubernetes Provider (Azure AKS) ─────────────────────────
provider "kubernetes" {
  alias = "aks"

  host                   = module.azure_aks.kube_config_host
  client_certificate     = base64decode(module.azure_aks.kube_config_client_certificate)
  client_key             = base64decode(module.azure_aks.kube_config_client_key)
  cluster_ca_certificate = base64decode(module.azure_aks.kube_config_ca_certificate)
}

# ─── Helm Provider (Azure AKS) ───────────────────────────────
provider "helm" {
  alias = "aks"

  kubernetes {
    host                   = module.azure_aks.kube_config_host
    client_certificate     = base64decode(module.azure_aks.kube_config_client_certificate)
    client_key             = base64decode(module.azure_aks.kube_config_client_key)
    cluster_ca_certificate = base64decode(module.azure_aks.kube_config_ca_certificate)
  }
}

# ─── Kubernetes Provider (GCP GKE) ───────────────────────────
provider "kubernetes" {
  alias = "gke"

  host                   = "https://${module.gcp_gke.cluster_endpoint}"
  cluster_ca_certificate = base64decode(module.gcp_gke.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

# ─── Helm Provider (GCP GKE) ─────────────────────────────────
provider "helm" {
  alias = "gke"

  kubernetes {
    host                   = "https://${module.gcp_gke.cluster_endpoint}"
    cluster_ca_certificate = base64decode(module.gcp_gke.cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

data "google_client_config" "default" {}
