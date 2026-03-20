# -----------------------------------------------------------------------------
# Azure Security Module
# Defender for Cloud (free tier), Azure Policy assignments for K8s,
# and Key Vault with RBAC authorization.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

# ─── Defender for Cloud (Free Tier) ──────────────────────────
resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = "Free"
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "kubernetes" {
  tier          = "Free"
  resource_type = "KubernetesService"
}

resource "azurerm_security_center_subscription_pricing" "key_vaults" {
  tier          = "Free"
  resource_type = "KeyVaults"
}

# ─── Azure Policy - No Privileged Containers ─────────────────
resource "azurerm_resource_group_policy_assignment" "no_privileged_containers" {
  name                 = "${local.name_prefix}-no-privileged"
  resource_group_id    = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/95edb821-ddaf-4404-9732-666045e056b4"
  display_name         = "Do not allow privileged containers in Kubernetes cluster"

  parameters = jsonencode({
    effect = {
      value = "Deny"
    }
  })
}

# ─── Azure Policy - Required Labels ──────────────────────────
resource "azurerm_resource_group_policy_assignment" "required_labels" {
  name                 = "${local.name_prefix}-req-labels"
  resource_group_id    = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/46592696-4c7b-4bf3-9e45-6c2763bdc0a6"
  display_name         = "Kubernetes cluster pods should use specified labels"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
    labelsList = {
      value = ["app", "environment"]
    }
  })
}

# ─── Azure Policy - Container CPU and Memory Limits ──────────
resource "azurerm_resource_group_policy_assignment" "container_limits" {
  name                 = "${local.name_prefix}-container-limits"
  resource_group_id    = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e345eecc-fa47-480f-9e88-67dcc122b164"
  display_name         = "Kubernetes cluster containers CPU and memory limits should not exceed"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
    maxAllowedCPU = {
      value = "2"
    }
    maxAllowedMemory = {
      value = "4Gi"
    }
  })
}

# ─── Key Vault ───────────────────────────────────────────────
resource "azurerm_key_vault" "this" {
  name                       = substr(replace("${local.name_prefix}kv", "-", ""), 0, 24)
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  purge_protection_enabled   = var.environment == "prd"
  soft_delete_retention_days = 30

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.common_tags
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

# ─── Key Vault Diagnostics ───────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "${local.name_prefix}-kv-diag"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
