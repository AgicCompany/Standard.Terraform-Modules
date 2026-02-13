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
  name     = "rg-rt-example-dev-weu-001"
  location = "westeurope"
}

module "route_table" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "rt-example-dev-weu-001"

  tags = {
    project     = "example"
    environment = "dev"
  }
}

output "route_table_id" {
  value = module.route_table.id
}

output "route_table_name" {
  value = module.route_table.name
}
