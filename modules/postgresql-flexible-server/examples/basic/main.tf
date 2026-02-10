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
  name     = "rg-psql-example-dev-weu-001"
  location = "westeurope"
}

resource "random_password" "admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "postgresql" {
  source = "../../"

  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  name                   = "psql-example-dev-weu-001"
  administrator_login    = "psqladmin"
  administrator_password = random_password.admin.result

  enable_password_auth = true
  enable_public_access = true

  databases = {
    appdb = {}
  }

  tags = {
    Environment = "dev"
    Module      = "postgresql-flexible-server"
    Example     = "basic"
  }
}

output "id" {
  value = module.postgresql.id
}

output "fqdn" {
  value = module.postgresql.fqdn
}
