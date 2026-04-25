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

  resource_group_name    = azurerm_resource_group.example.name
  location               = azurerm_resource_group.example.location
  name                   = "psql-example-dev-weu-001"
  administrator_login    = "psqladmin"
  administrator_password = random_password.admin.result

  enable_private_endpoint = false
  enable_password_auth    = true
  enable_public_access    = true

  entra_admin_object_id      = "00000000-0000-0000-0000-000000000000"
  entra_admin_principal_name = "DBA Team"

  databases = {
    appdb = {}
  }

  tags = {
    project     = "postgresql-flexible-server"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.postgresql.id
}

output "fqdn" {
  value = module.postgresql.fqdn
}
