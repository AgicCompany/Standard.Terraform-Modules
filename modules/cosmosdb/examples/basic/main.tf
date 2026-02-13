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
  name     = "rg-cosmos-example-dev-weu-001"
  location = "westeurope"
}

module "cosmosdb" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "cosmos-example-dev-weu-001"

  free_tier_enabled = true

  sql_databases = {
    appdb = {}
  }

  enable_private_endpoint = false
  enable_public_access    = true

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.cosmosdb.id
}

output "endpoint" {
  value = module.cosmosdb.endpoint
}
