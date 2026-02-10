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
  name     = "rg-cosmos-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-cosmos-complete-dev-weu-001"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "pe" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  name                  = "cosmos-dns-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

module "cosmosdb" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "cosmos-complete-dev-weu-001"

  automatic_failover_enabled = true

  consistency_policy = {
    consistency_level = "Session"
  }

  sql_databases = {
    appdb = {}
    analyticsdb = {
      max_throughput = 4000
    }
  }

  backup = {
    type = "Continuous"
  }

  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.pe.id
  private_dns_zone_id     = azurerm_private_dns_zone.cosmos.id

  tags = {
    Environment = "dev"
    Project     = "complete-example"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.cosmos]
}

output "id" {
  value = module.cosmosdb.id
}

output "endpoint" {
  value = module.cosmosdb.endpoint
}

output "private_endpoint_id" {
  value = module.cosmosdb.private_endpoint_id
}

output "database_ids" {
  value = module.cosmosdb.database_ids
}
