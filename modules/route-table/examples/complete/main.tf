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
  name     = "rg-rt-complete-dev-weu-001"
  location = "westeurope"
}

module "route_table" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "rt-complete-dev-weu-001"

  disable_bgp_route_propagation = true

  routes = {
    to-internet = {
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
    to-firewall = {
      address_prefix         = "10.0.0.0/8"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    }
    to-vnet = {
      address_prefix = "172.16.0.0/12"
      next_hop_type  = "VnetLocal"
    }
  }

  tags = {
    project     = "route-table-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "route_table_id" {
  value = module.route_table.id
}

output "route_table_name" {
  value = module.route_table.name
}

output "route_ids" {
  value = module.route_table.route_ids
}
