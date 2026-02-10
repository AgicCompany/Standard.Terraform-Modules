terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-psql-complete-dev-weu-001"
  location = "westeurope"
}

resource "random_password" "admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# --- Networking ---

resource "azurerm_virtual_network" "this" {
  name                = "vnet-psql-complete-dev-weu-001"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "postgresql" {
  name                 = "snet-psql"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "postgresql"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "psql-vnet-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# --- PostgreSQL Flexible Server ---

module "postgresql" {
  source = "../../"

  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  name                   = "psql-complete-dev-weu-001"
  administrator_login    = "psqladmin"
  administrator_password = random_password.admin.result
  enable_password_auth   = true

  sku_name              = "GP_Standard_D2s_v3"
  version_number        = "16"
  storage_mb            = 65536
  backup_retention_days = 14

  # VNet integration
  delegated_subnet_id = azurerm_subnet.postgresql.id
  private_dns_zone_id = azurerm_private_dns_zone.postgresql.id

  # Maintenance window: Sunday at 02:00
  maintenance_window = {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  # Databases
  databases = {
    appdb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
    analyticsdb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }

  # Server configurations
  server_configurations = {
    "shared_preload_libraries"   = "pg_stat_statements"
    "log_min_duration_statement" = "1000"
  }

  tags = {
    Environment = "dev"
    Module      = "postgresql-flexible-server"
    Example     = "complete"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgresql
  ]
}

output "id" {
  value = module.postgresql.id
}

output "fqdn" {
  value = module.postgresql.fqdn
}

output "database_ids" {
  value = module.postgresql.database_ids
}
