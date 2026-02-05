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

resource "azurerm_resource_group" "example" {
  name     = "rg-vnet-complete-dev-weu-001"
  location = "westeurope"
}

# Network Security Groups for demonstration
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allow-sql-from-app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }
}

# Route table for demonstration
resource "azurerm_route_table" "data" {
  name                = "rt-data-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.254.4"
  }
}

module "virtual_network" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "vnet-complete-dev-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    # Application subnet with NSG and service endpoints
    snet-app = {
      address_prefixes                  = ["10.0.1.0/24"]
      network_security_group_id         = azurerm_network_security_group.app.id
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Disabled"
    }

    # Data subnet with NSG and route table
    snet-data = {
      address_prefixes          = ["10.0.2.0/24"]
      network_security_group_id = azurerm_network_security_group.data.id
      route_table_id            = azurerm_route_table.data.id
    }

    # Private endpoint subnet
    snet-private-endpoints = {
      address_prefixes                  = ["10.0.3.0/24"]
      private_endpoint_network_policies = "Disabled"
    }

    # App Service delegation subnet
    snet-appservice = {
      address_prefixes = ["10.0.4.0/24"]
      delegation = {
        name = "appservice"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }

    # Container Apps delegation subnet
    snet-container-apps = {
      address_prefixes = ["10.0.5.0/23"]
      delegation = {
        name = "containerapps"
        service_delegation = {
          name    = "Microsoft.App/environments"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "vnet_name" {
  value = module.virtual_network.name
}

output "address_space" {
  value = module.virtual_network.address_space
}

output "subnet_ids" {
  value = module.virtual_network.subnet_ids
}

output "subnet_address_prefixes" {
  value = module.virtual_network.subnet_address_prefixes
}
