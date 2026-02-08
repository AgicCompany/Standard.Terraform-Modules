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
  name     = "rg-log-example-dev-weu-001"
  location = "westeurope"
}

module "log_analytics" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "log-example-dev-weu-001"

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "workspace_id" {
  value = module.log_analytics.id
}

output "workspace_guid" {
  value = module.log_analytics.workspace_id
}
