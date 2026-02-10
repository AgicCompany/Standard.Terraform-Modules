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

resource "azurerm_resource_group" "this" {
  name     = "rg-cosmos-example-dev-weu-001"
  location = "westeurope"
}

module "cosmosdb" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "cosmos-example-dev-weu-001"

  free_tier_enabled = true

  sql_databases = {
    appdb = {}
  }

  enable_private_endpoint = false
  enable_public_access    = true

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

output "id" {
  value = module.cosmosdb.id
}

output "endpoint" {
  value = module.cosmosdb.endpoint
}
