# Azure Networking Module

Provisions an Azure Virtual Network (VNet) with configurable subnets, Azure Firewall for centralized network security, and route tables for traffic management across the network topology.

## Usage

```hcl
module "networking" {
  source = "./modules/azure/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"

  vnet_name          = "production-vnet"
  vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    aks = {
      name             = "aks-subnet"
      address_prefixes = ["10.0.0.0/20"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    appgw = {
      name             = "appgw-subnet"
      address_prefixes = ["10.0.16.0/24"]
    }
    firewall = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.17.0/24"]
    }
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.18.0/24"]
    }
  }

  # Azure Firewall
  enable_firewall     = true
  firewall_name       = "production-firewall"
  firewall_sku_tier   = "Standard"
  firewall_policy_name = "production-fw-policy"
  firewall_network_rules = [
    {
      name                  = "allow-ntp"
      protocols             = ["UDP"]
      source_addresses      = ["10.0.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
  ]
  firewall_application_rules = [
    {
      name              = "allow-azure-services"
      source_addresses  = ["10.0.0.0/16"]
      target_fqdns      = ["*.azmk8s.io", "mcr.microsoft.com"]
      protocol = {
        type = "Https"
        port = 443
      }
    }
  ]

  # Route tables
  enable_route_table = true
  routes = [
    {
      name                   = "default-route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.17.4"
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
| `vnet_name` | Name of the Virtual Network | `string` | n/a | yes |
| `vnet_address_space` | Address space for the VNet | `list(string)` | n/a | yes |
| `subnets` | Map of subnet configurations | `map(object)` | `{}` | no |
| `enable_firewall` | Enable Azure Firewall | `bool` | `false` | no |
| `firewall_name` | Name of the Azure Firewall | `string` | `""` | no |
| `firewall_sku_tier` | SKU tier of Azure Firewall (Standard or Premium) | `string` | `"Standard"` | no |
| `firewall_policy_name` | Name of the firewall policy | `string` | `""` | no |
| `firewall_network_rules` | List of network rule configurations | `list(object)` | `[]` | no |
| `firewall_application_rules` | List of application rule configurations | `list(object)` | `[]` | no |
| `enable_route_table` | Enable custom route table | `bool` | `false` | no |
| `routes` | List of route configurations | `list(object)` | `[]` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vnet_id` | The ID of the Virtual Network |
| `vnet_name` | The name of the Virtual Network |
| `vnet_address_space` | The address space of the VNet |
| `subnet_ids` | Map of subnet names to their IDs |
| `aks_subnet_id` | The ID of the AKS subnet |
| `firewall_private_ip` | The private IP of the Azure Firewall |
| `firewall_public_ip` | The public IP of the Azure Firewall |
| `route_table_id` | The ID of the route table |
