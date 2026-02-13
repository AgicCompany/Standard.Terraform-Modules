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
  name     = "rg-natgw-example-dev-weu-001"
  location = "westeurope"
}

module "nat_gateway" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "natgw-example-dev-weu-001"

  tags = {
    project     = "nat-gateway"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "nat_gateway_id" {
  value = module.nat_gateway.id
}

output "nat_gateway_name" {
  value = module.nat_gateway.name
}

output "public_ip_address" {
  value = module.nat_gateway.public_ip_address
}
