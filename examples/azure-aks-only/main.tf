# =============================================================================
# Azure AKS-Only Example
# Deploys: VNet + AKS + Defender + Policy + Key Vault
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply -var="subscription_id=YOUR_SUB" -var="tenant_id=YOUR_TENANT"
#   az aks get-credentials --name $(terraform output -raw cluster_name) --resource-group $(terraform output -raw resource_group)
#   kubectl get nodes
#
# Estimated cost: ~$80/month
# Deploy time: ~10 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "subscription_id" { type = string }
variable "tenant_id" { type = string }
variable "location" {
  type    = string
  default = "westeurope"
}

locals {
  project     = "aks-example"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.project}-${local.environment}-rg"
  location = var.location
  tags     = local.tags
}

module "networking" {
  source = "../../modules/azure/networking"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_cidr           = "10.1.0.0/16"
  enable_firewall     = false
  tags                = local.tags
}

module "aks" {
  source = "../../modules/azure/aks"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  subnet_id           = module.networking.aks_subnet_id
  system_node_vm_size = "Standard_B2s"
  user_node_vm_size   = "Standard_B2s"
  user_node_min_count = 1
  user_node_max_count = 3
  tags                = local.tags
}

module "security" {
  source = "../../modules/azure/security"

  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tenant_id           = var.tenant_id
  tags                = local.tags
}

output "cluster_name" { value = module.aks.cluster_name }
output "resource_group" { value = azurerm_resource_group.main.name }
output "kubeconfig_cmd" {
  value = "az aks get-credentials --name ${module.aks.cluster_name} --resource-group ${azurerm_resource_group.main.name}"
}
