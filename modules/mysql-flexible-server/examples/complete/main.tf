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
  name     = "rg-mysql-complete-dev-weu-001"
  location = "westeurope"
}

resource "random_password" "admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# --- Networking ---

resource "azurerm_virtual_network" "this" {
  name                = "vnet-mysql-complete-dev-weu-001"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mysql" {
  name                 = "snet-mysql"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "mysql"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-vnet-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# --- MySQL Flexible Server ---

module "mysql" {
  source = "../../"

  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  name                   = "mysql-complete-dev-weu-001"
  administrator_login    = "mysqladmin"
  administrator_password = random_password.admin.result

  sku_name       = "GP_Standard_D2ds_v4"
  version_number = "8.0.21"

  storage = {
    size_gb           = 64
    auto_grow_enabled = true
  }

  backup_retention_days = 14

  # VNet integration
  delegated_subnet_id = azurerm_subnet.mysql.id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id

  # Maintenance window: Sunday at 02:00
  maintenance_window = {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  # Databases
  databases = {
    appdb = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
    analyticsdb = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  }

  # Server configurations
  server_configurations = {
    "slow_query_log"  = "ON"
    "long_query_time" = "2"
  }

  tags = {
    Environment = "dev"
    Module      = "mysql-flexible-server"
    Example     = "complete"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.mysql
  ]
}

output "id" {
  value = module.mysql.id
}

output "fqdn" {
  value = module.mysql.fqdn
}

output "database_ids" {
  value = module.mysql.database_ids
}
