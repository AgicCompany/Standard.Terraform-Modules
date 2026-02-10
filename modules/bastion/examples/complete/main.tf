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
  name     = "rg-bas-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-bas-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/26"]
}

module "bastion" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "bas-complete-dev-weu-001"
  subnet_id           = azurerm_subnet.bastion.id

  sku = "Standard"

  tunneling_enabled  = true
  ip_connect_enabled = true
  file_copy_enabled  = true
  scale_units        = 4

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.bastion.id
}

output "name" {
  value = module.bastion.name
}

output "dns_name" {
  value = module.bastion.dns_name
}

output "public_ip_address" {
  value = module.bastion.public_ip_address
}
