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

resource "azurerm_resource_group" "example" {
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
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "pe" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "psql-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# --- PostgreSQL Flexible Server (Private Endpoint mode) ---

module "postgresql" {
  source = "../../"

  resource_group_name    = azurerm_resource_group.example.name
  location               = azurerm_resource_group.example.location
  name                   = "psql-complete-dev-weu-001"
  administrator_login    = "psqladmin"
  administrator_password = random_password.admin.result
  enable_password_auth   = true

  entra_admin_object_id      = "00000000-0000-0000-0000-000000000000"
  entra_admin_principal_name = "DBA Team"

  sku_name              = "GP_Standard_D2s_v3"
  version_number        = "16"
  storage_mb            = 65536
  backup_retention_days = 14

  # Private endpoint (default: enabled)
  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.pe.id
  private_dns_zone_id     = azurerm_private_dns_zone.postgresql.id

  # Alternative: VNet delegation (mutually exclusive with PE)
  # enable_private_endpoint = false
  # delegated_subnet_id     = azurerm_subnet.psql_delegated.id
  # private_dns_zone_id     = azurerm_private_dns_zone.postgresql.id

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
    project     = "postgresql-flexible-server"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
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

output "private_endpoint_id" {
  value = module.postgresql.private_endpoint_id
}

output "private_ip_address" {
  value = module.postgresql.private_ip_address
}
