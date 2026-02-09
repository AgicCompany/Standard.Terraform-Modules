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
  name     = "rg-aks-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-dev-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "aks" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aks-payments-dev-weu-001"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    environment = "dev"
    project     = "payments"
  }
}

output "cluster_id" {
  value = module.aks.id
}

output "cluster_name" {
  value = module.aks.name
}
