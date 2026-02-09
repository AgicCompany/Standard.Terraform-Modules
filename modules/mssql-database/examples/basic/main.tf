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
  name     = "rg-data-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_mssql_server" "example" {
  name                = "sql-myapp-dev-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  version             = "12.0"

  azuread_administrator {
    login_username              = "sqladmin@example.com"
    object_id                   = data.azurerm_client_config.current.object_id
    azuread_authentication_only = true
  }

  tags = {
    environment = "dev"
    project     = "myapp"
  }
}

module "database" {
  source = "../../"

  name      = "myapp-api"
  server_id = azurerm_mssql_server.example.id

  tags = {
    environment = "dev"
    project     = "myapp"
  }
}

output "database_id" {
  value = module.database.id
}

output "database_name" {
  value = module.database.name
}
