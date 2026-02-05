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
  name     = "rg-vnet-example-dev-weu-001"
  location = "westeurope"
}

module "virtual_network" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "vnet-example-dev-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-app = {
      address_prefixes = ["10.0.1.0/24"]
    }
    snet-data = {
      address_prefixes = ["10.0.2.0/24"]
    }
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "subnet_ids" {
  value = module.virtual_network.subnet_ids
}
