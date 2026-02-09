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
  name     = "rg-acr-example-dev-weu-001"
  location = "westeurope"
}

module "container_registry" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "crpaymentsdevweu001"
  sku                 = "Premium"

  enable_private_endpoint = false

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "registry_id" {
  value = module.container_registry.id
}

output "login_server" {
  value = module.container_registry.login_server
}
