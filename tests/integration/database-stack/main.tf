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

data "azurerm_client_config" "current" {}

# --- Resource Group ---

resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-database-neu-001"
  location = "northeurope"
}

# --- Module 1: Virtual Network ---

module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-database-neu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-pe = {
      address_prefixes                  = ["10.0.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# --- Module 2: Private DNS Zone ---

module "private_dns_zone" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.database.windows.net"

  virtual_network_links = {
    vnet-database = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# --- Module 3: SQL Server (with PE, AAD-only) ---

module "mssql_server" {
  source = "../../../modules/mssql-server"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "sql-tftest-database-neu-001"

  azuread_administrator = {
    login_username = "sqladmin@tftest.com"
    object_id      = data.azurerm_client_config.current.object_id
  }

  # Private endpoint
  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.private_dns_zone.id

  tags = { environment = "test", project = "tftest" }
}

# --- Module 4: SQL Database ---

module "mssql_database" {
  source = "../../../modules/mssql-database"

  name      = "tftest-api"
  server_id = module.mssql_server.id
  sku_name  = "S0"

  tags = { environment = "test", project = "tftest" }
}

# --- Outputs ---

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "sql_server_id" {
  value = module.mssql_server.id
}

output "sql_server_fqdn" {
  value = module.mssql_server.fully_qualified_domain_name
}

output "database_id" {
  value = module.mssql_database.id
}

output "database_name" {
  value = module.mssql_database.name
}
