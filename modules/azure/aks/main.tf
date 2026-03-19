# -----------------------------------------------------------------------------
# Azure AKS Module
# AKS cluster with system + user node pools, Azure CNI, AAD RBAC,
# Key Vault CSI driver, and Azure Policy addon.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ─── User Assigned Identity ──────────────────────────────────
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.cluster_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

# ─── Log Analytics Workspace ─────────────────────────────────
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.cluster_name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 90 : 30

  tags = var.common_tags
}

# ─── AKS Cluster ─────────────────────────────────────────────
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  # System Node Pool
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    min_count                    = var.system_node_count
    max_count                    = var.system_node_max_count
    enable_auto_scaling          = true
    vnet_subnet_id               = var.vnet_subnet_id
    os_disk_size_gb              = 50
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    zones                        = var.environment == "prd" ? ["1", "2", "3"] : ["1"]
    only_critical_addons_enabled = true

    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Azure CNI Networking
  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  # AAD RBAC
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    managed            = true
  }

  # OMS Agent (Container Insights)
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  # Azure Policy Addon
  azure_policy_enabled = true

  # Key Vault CSI Driver
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # OIDC Issuer for Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Autoscaler Profile
  auto_scaler_profile {
    balance_similar_node_groups = true
    scale_down_delay_after_add  = "10m"
    scale_down_unneeded         = "10m"
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

# ─── User/Workload Node Pool ─────────────────────────────────
resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.system_node_vm_size
  min_count             = 1
  max_count             = var.system_node_max_count
  enable_auto_scaling   = true
  vnet_subnet_id        = var.vnet_subnet_id
  os_disk_size_gb       = 100
  zones                 = var.environment == "prd" ? ["1", "2", "3"] : ["1"]

  node_labels = {
    role        = "workload"
    environment = var.environment
  }

  node_taints = []

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [node_count]
  }
}
