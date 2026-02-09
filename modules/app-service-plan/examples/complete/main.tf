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
  name     = "rg-asp-complete-dev-weu-001"
  location = "westeurope"
}

module "app_plan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "asp-payments-prod-weu-001"
  sku_name            = "P1v3"

  worker_count            = 3
  enable_zone_redundancy  = true
  enable_per_site_scaling = true

  tags = {
    environment = "prod"
    project     = "payments"
    cost_center = "finance"
  }
}

output "plan_id" {
  value = module.app_plan.id
}

output "plan_name" {
  value = module.app_plan.name
}
