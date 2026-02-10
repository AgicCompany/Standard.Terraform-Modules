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

resource "azurerm_resource_group" "example" {
  name     = "rg-ag-example-dev-weu-001"
  location = "westeurope"
}

module "action_group" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  name                = "ag-example-dev-weu-001"
  short_name          = "ag-example"

  email_receivers = {
    platform-team = {
      email_address = "platform@company.com"
    }
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "action_group_id" {
  value = module.action_group.id
}
