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
  name     = "rg-peering-example-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.1.0.0/16"]
}

module "vnet_peering" {
  source = "../../"

  name = "hub-to-spoke"

  virtual_network_id                  = azurerm_virtual_network.hub.id
  virtual_network_resource_group_name = azurerm_resource_group.example.name
  virtual_network_name                = azurerm_virtual_network.hub.name

  remote_virtual_network_id                  = azurerm_virtual_network.spoke.id
  remote_virtual_network_resource_group_name = azurerm_resource_group.example.name
  remote_virtual_network_name                = azurerm_virtual_network.spoke.name

  tags = {
    project     = "example"
    environment = "dev"
  }
}

output "local_to_remote_peering_id" {
  value = module.vnet_peering.local_to_remote_id
}

output "remote_to_local_peering_id" {
  value = module.vnet_peering.remote_to_local_id
}
