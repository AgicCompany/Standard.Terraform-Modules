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
  name     = "rg-mysql-example-dev-weu-001"
  location = "westeurope"
}

resource "random_password" "admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "mysql" {
  source = "../../"

  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  name                   = "mysql-example-dev-weu-001"
  administrator_login    = "mysqladmin"
  administrator_password = random_password.admin.result

  enable_public_access = true

  databases = {
    appdb = {}
  }

  tags = {
    Environment = "dev"
    Module      = "mysql-flexible-server"
    Example     = "basic"
  }
}

output "id" {
  value = module.mysql.id
}

output "fqdn" {
  value = module.mysql.fqdn
}
