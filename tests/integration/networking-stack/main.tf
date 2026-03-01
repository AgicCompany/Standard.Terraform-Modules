############################################
# Integration Test: Networking Stack
# Covers: network-security-group, route-table,
#          nat-gateway, vnet-peering, bastion
############################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-networking-weu-001"
  location = "westeurope"
  tags     = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Hub VNet (bastion host)
# -----------------------------------------------------------------------------
module "hub_vnet" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-hub-weu-001"
  address_space       = ["10.1.0.0/16"]

  subnets = {
    AzureBastionSubnet = {
      address_prefixes = ["10.1.0.0/26"]
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Spoke VNet (workload subnet)
# -----------------------------------------------------------------------------
module "spoke_vnet" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-spoke-weu-001"
  address_space       = ["10.2.0.0/16"]

  subnets = {
    snet-workload = {
      address_prefixes = ["10.2.1.0/24"]
    }
  }

  subnet_nsg_associations = {
    snet-workload = module.nsg.id
  }

  subnet_route_table_associations = {
    snet-workload = module.route_table.id
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Network Security Group
# -----------------------------------------------------------------------------
module "nsg" {
  source = "../../../modules/network-security-group"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "nsg-tftest-workload-weu-001"

  security_rules = {
    allow-ssh = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow SSH within VNet"
    }
    allow-rdp = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow RDP within VNet"
    }
    deny-internet-inbound = {
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny all inbound from Internet"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Route Table
# -----------------------------------------------------------------------------
module "route_table" {
  source = "../../../modules/route-table"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "rt-tftest-workload-weu-001"

  routes = {
    default-route = {
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# NAT Gateway
# -----------------------------------------------------------------------------
module "nat_gateway" {
  source = "../../../modules/nat-gateway"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "ng-tftest-workload-weu-001"

  tags = { environment = "test", project = "tftest" }
}

# Associate NAT Gateway to workload subnet (module doesn't handle this)
resource "azurerm_subnet_nat_gateway_association" "workload" {
  subnet_id      = module.spoke_vnet.subnet_ids["snet-workload"]
  nat_gateway_id = module.nat_gateway.id
}

# -----------------------------------------------------------------------------
# VNet Peering (hub <-> spoke)
# -----------------------------------------------------------------------------
module "vnet_peering" {
  source = "../../../modules/vnet-peering"

  name = "peer-tftest-hub-spoke-weu-001"

  virtual_network_id                  = module.hub_vnet.id
  virtual_network_resource_group_name = azurerm_resource_group.this.name
  virtual_network_name                = module.hub_vnet.name

  remote_virtual_network_id                  = module.spoke_vnet.id
  remote_virtual_network_resource_group_name = azurerm_resource_group.this.name
  remote_virtual_network_name                = module.spoke_vnet.name

  allow_forwarded_traffic = true
}

# -----------------------------------------------------------------------------
# Bastion
# -----------------------------------------------------------------------------
module "bastion" {
  source = "../../../modules/bastion"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "bas-tftest-hub-weu-001"
  subnet_id           = module.hub_vnet.subnet_ids["AzureBastionSubnet"]

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "hub_vnet_id" {
  value = module.hub_vnet.id
}

output "spoke_vnet_id" {
  value = module.spoke_vnet.id
}

output "nsg_id" {
  value = module.nsg.id
}

output "route_table_id" {
  value = module.route_table.id
}

output "nat_gateway_id" {
  value = module.nat_gateway.id
}

output "nat_gateway_public_ip" {
  value = module.nat_gateway.public_ip_address
}

output "vnet_peering_id" {
  value = module.vnet_peering.id
}

output "bastion_id" {
  value = module.bastion.id
}

output "bastion_dns_name" {
  value = module.bastion.dns_name
}
