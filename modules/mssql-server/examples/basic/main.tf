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
  name     = "rg-sql-example-dev-weu-001"
  location = "westeurope"
}

module "sql_server" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "sql-payments-dev-weu-001"

  azuread_administrator = {
    login_username = "sqladmin@contoso.com"
    object_id      = data.azurerm_client_config.current.object_id
  }

  enable_private_endpoint = false

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "sql_server_id" {
  value = module.sql_server.id
}

output "sql_server_fqdn" {
  value = module.sql_server.fully_qualified_domain_name
}
