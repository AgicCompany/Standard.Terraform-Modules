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

resource "azurerm_resource_group" "example" {
  name     = "rg-sqldb-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_mssql_server" "example" {
  name                = "sql-payments-prod-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  version             = "12.0"
  minimum_tls_version = "1.2"

  azuread_administrator {
    login_username              = "sqladmin@contoso.com"
    object_id                   = data.azurerm_client_config.current.object_id
    azuread_authentication_only = true
  }

  tags = {
    environment = "prod"
    project     = "payments"
    cost_center = "finance"
  }
}

module "database" {
  source = "../../"

  name      = "payments-api"
  server_id = azurerm_mssql_server.example.id
  sku_name  = "P1"

  max_size_gb  = 50
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"

  short_term_retention_days   = 35
  enable_zone_redundancy      = true
  enable_geo_redundant_backup = true
  enable_read_scale           = true

  tags = {
    environment = "prod"
    project     = "payments"
    cost_center = "finance"
  }
}

output "database_id" {
  value = module.database.id
}

output "database_name" {
  value = module.database.name
}
