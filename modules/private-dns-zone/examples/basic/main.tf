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
  name     = "rg-dns-example-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

module "dns_blob" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  name                = "privatelink.blob.core.windows.net"

  virtual_network_links = {
    vnet-link = {
      virtual_network_id = azurerm_virtual_network.example.id
    }
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "dns_zone_id" {
  value = module.dns_blob.id
}

output "vnet_link_ids" {
  value = module.dns_blob.virtual_network_link_ids
}
