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
  name     = "rg-identity-example-dev-weu-001"
  location = "westeurope"
}

module "identity" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "id-example-dev-weu-001"

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "identity_id" {
  value = module.identity.id
}

output "principal_id" {
  value = module.identity.principal_id
}

output "client_id" {
  value = module.identity.client_id
}
