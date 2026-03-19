# -----------------------------------------------------------------------------
# Azure Networking Module
# VNet, AKS subnet, firewall subnet, Azure Firewall with policy,
# route table for AKS traffic through firewall, and private endpoints.
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ─── Resource Group ──────────────────────────────────────────
resource "azurerm_resource_group" "this" {
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = var.common_tags
}

# ─── Virtual Network ─────────────────────────────────────────
resource "azurerm_virtual_network" "this" {
  name                = "${local.name_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.common_tags
}

# ─── AKS Subnet ──────────────────────────────────────────────
resource "azurerm_subnet" "aks" {
  name                 = "${local.name_prefix}-snet-aks"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 4, 0)]
}

# ─── Azure Firewall Subnet (must be named AzureFirewallSubnet) ─
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 254)]
}

# ─── Private Endpoints Subnet ────────────────────────────────
resource "azurerm_subnet" "private_endpoints" {
  name                 = "${local.name_prefix}-snet-pe"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 10)]

  private_endpoint_network_policies_enabled = true
}

# ─── Azure Firewall Public IP ────────────────────────────────
resource "azurerm_public_ip" "firewall" {
  name                = "${local.name_prefix}-fw-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.common_tags
}

# ─── Azure Firewall Policy ───────────────────────────────────
resource "azurerm_firewall_policy" "this" {
  name                = "${local.name_prefix}-fw-policy"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"

  dns {
    proxy_enabled = true
  }

  tags = var.common_tags
}

# ─── Firewall Policy Rule Collection Group ───────────────────
resource "azurerm_firewall_policy_rule_collection_group" "aks" {
  name               = "${local.name_prefix}-aks-rules"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  network_rule_collection {
    name     = "aks-network-rules"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-aks-api"
      protocols             = ["TCP"]
      source_addresses      = [cidrsubnet(var.vnet_cidr, 4, 0)]
      destination_addresses = ["AzureCloud"]
      destination_ports     = ["443", "9000"]
    }

    rule {
      name                  = "allow-ntp"
      protocols             = ["UDP"]
      source_addresses      = [cidrsubnet(var.vnet_cidr, 4, 0)]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
  }

  application_rule_collection {
    name     = "aks-app-rules"
    priority = 200
    action   = "Allow"

    rule {
      name = "allow-aks-fqdn"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = [cidrsubnet(var.vnet_cidr, 4, 0)]
      destination_fqdns = [
        "*.hcp.${var.location}.azmk8s.io",
        "mcr.microsoft.com",
        "*.data.mcr.microsoft.com",
        "management.azure.com",
        "login.microsoftonline.com",
        "packages.microsoft.com",
        "acs-mirror.azureedge.net",
        "dc.services.visualstudio.com",
        "*.monitoring.azure.com",
        "*.oms.opinsights.azure.com",
        "*.ods.opinsights.azure.com",
      ]
    }
  }
}

# ─── Azure Firewall ──────────────────────────────────────────
resource "azurerm_firewall" "this" {
  name                = "${local.name_prefix}-fw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.this.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = var.common_tags
}

# ─── Route Table for AKS through Firewall ────────────────────
resource "azurerm_route_table" "aks" {
  name                = "${local.name_prefix}-rt-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
  }

  tags = var.common_tags
}

resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.aks.id
}

# ─── Network Security Group ──────────────────────────────────
resource "azurerm_network_security_group" "aks" {
  name                = "${local.name_prefix}-nsg-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

# ─── Network Watcher ─────────────────────────────────────────
resource "azurerm_network_watcher" "this" {
  name                = "${local.name_prefix}-nw"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.common_tags
}
