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
  name     = "rg-app-dev-weu-001"
  location = "westeurope"
}

module "app_plan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "asp-myapp-dev-weu-001"
  sku_name            = "B1"

  tags = {
    environment = "dev"
    project     = "myapp"
  }
}

output "plan_id" {
  value = module.app_plan.id
}

output "plan_name" {
  value = module.app_plan.name
}
