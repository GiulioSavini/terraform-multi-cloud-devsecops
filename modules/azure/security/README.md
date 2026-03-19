# Azure Security Module

Provisions Azure security services including Microsoft Defender for Cloud for threat protection, Azure Policy for governance and compliance enforcement, and Azure Key Vault for centralized secrets and certificate management.

## Usage

```hcl
module "security" {
  source = "./modules/azure/security"

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  environment         = "production"

  # Microsoft Defender for Cloud
  enable_defender = true
  defender_plans = {
    AppServices        = "Standard"
    ContainerRegistry  = "Standard"
    KeyVaults          = "Standard"
    KubernetesService  = "Standard"
    SqlServers         = "Standard"
    StorageAccounts    = "Standard"
    VirtualMachines    = "Standard"
  }
  defender_contact_email = "security@example.com"
  defender_contact_phone = "+1-555-0100"
  defender_alert_notifications = true

  # Azure Policy
  enable_azure_policy = true
  policy_assignments = {
    allowed_locations = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
      parameters = {
        listOfAllowedLocations = ["eastus2", "westus2", "centralus"]
      }
    }
    require_tag_environment = {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b466-ef6698e5be9e"
      parameters = {
        tagName = "Environment"
      }
    }
  }

  # Azure Key Vault
  enable_key_vault   = true
  key_vault_name     = "prod-kv-001"
  key_vault_sku      = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  enable_rbac_authorization  = true

  key_vault_access_policies = [
    {
      object_id = "00000000-0000-0000-0000-000000000000"
      secret_permissions      = ["Get", "List"]
      key_permissions         = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }
  ]

  tags = {
    Environment = "production"
    Project     = "multi-cloud-platform"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `resource_group_name` | Name of the Azure resource group | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `environment` | Environment name | `string` | n/a | yes |
| `enable_defender` | Enable Microsoft Defender for Cloud | `bool` | `true` | no |
| `defender_plans` | Map of Defender plan names to pricing tiers | `map(string)` | `{}` | no |
| `defender_contact_email` | Security contact email address | `string` | `""` | no |
| `defender_contact_phone` | Security contact phone number | `string` | `""` | no |
| `defender_alert_notifications` | Enable alert email notifications | `bool` | `true` | no |
| `enable_azure_policy` | Enable Azure Policy assignments | `bool` | `true` | no |
| `policy_assignments` | Map of Azure Policy assignment configurations | `map(object)` | `{}` | no |
| `enable_key_vault` | Enable Azure Key Vault | `bool` | `true` | no |
| `key_vault_name` | Name of the Key Vault | `string` | `""` | no |
| `key_vault_sku` | SKU name of the Key Vault (standard or premium) | `string` | `"standard"` | no |
| `soft_delete_retention_days` | Number of days to retain soft-deleted items | `number` | `90` | no |
| `purge_protection_enabled` | Enable purge protection on the Key Vault | `bool` | `true` | no |
| `enable_rbac_authorization` | Enable RBAC authorization for Key Vault | `bool` | `true` | no |
| `key_vault_access_policies` | List of Key Vault access policy configurations | `list(object)` | `[]` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `key_vault_id` | The ID of the Azure Key Vault |
| `key_vault_uri` | The URI of the Azure Key Vault |
| `key_vault_name` | The name of the Azure Key Vault |
| `defender_subscription_id` | The subscription ID with Defender enabled |
| `policy_assignment_ids` | Map of policy assignment names to their IDs |
