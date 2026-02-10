############################################
# Integration Test: OSS Database Stack
# Covers: mysql-flexible-server,
#          postgresql-flexible-server
# Region: swedencentral (MySQL/PostgreSQL
#          blocked in westeurope)
############################################

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

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-ossdb-sec-001"
  location = "swedencentral"
  tags     = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Virtual Network with delegated subnets
# -----------------------------------------------------------------------------
module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-ossdb-sec-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-mysql = {
      address_prefixes = ["10.0.1.0/24"]
      delegation = {
        name = "mysql"
        service_delegation = {
          name    = "Microsoft.DBforMySQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
    snet-postgres = {
      address_prefixes = ["10.0.2.0/24"]
      delegation = {
        name = "postgres"
        service_delegation = {
          name    = "Microsoft.DBforPostgreSQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Private DNS Zones
# -----------------------------------------------------------------------------
module "dns_mysql" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.mysql.database.azure.com"

  virtual_network_links = {
    ossdb-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

module "dns_postgres" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.postgres.database.azure.com"

  virtual_network_links = {
    ossdb-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Passwords
# -----------------------------------------------------------------------------
resource "random_password" "mysql" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*"
}

resource "random_password" "postgres" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*"
}

# -----------------------------------------------------------------------------
# MySQL Flexible Server
# -----------------------------------------------------------------------------
module "mysql" {
  source = "../../../modules/mysql-flexible-server"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "mysql-tftest-ossdb-sec-001"

  sku_name               = "B_Standard_B1ms"
  administrator_login    = "mysqladmin"
  administrator_password = random_password.mysql.result

  delegated_subnet_id = module.virtual_network.subnet_ids["snet-mysql"]
  private_dns_zone_id = module.dns_mysql.id

  databases = {
    testdb = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  }

  # DNS zone VNet link must be fully provisioned before server creation
  depends_on = [module.dns_mysql]

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# PostgreSQL Flexible Server
# -----------------------------------------------------------------------------
module "postgresql" {
  source = "../../../modules/postgresql-flexible-server"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "psql-tftest-ossdb-sec-001"

  sku_name               = "B_Standard_B1ms"
  administrator_login    = "pgadmin"
  administrator_password = random_password.postgres.result

  delegated_subnet_id = module.virtual_network.subnet_ids["snet-postgres"]
  private_dns_zone_id = module.dns_postgres.id

  # DNS zone VNet link must be fully provisioned before server creation
  depends_on = [module.dns_postgres]

  databases = {
    testdb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "mysql_server_id" {
  value = module.mysql.id
}

output "mysql_server_fqdn" {
  value = module.mysql.fqdn
}

output "postgresql_server_id" {
  value = module.postgresql.id
}

output "postgresql_server_fqdn" {
  value = module.postgresql.fqdn
}
