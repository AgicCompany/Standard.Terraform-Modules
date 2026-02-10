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

resource "azurerm_resource_group" "this" {
  name     = "rg-appi-example-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-appi-example-dev-weu-001"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "application_insights" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "appi-example-dev-weu-001"
  workspace_id        = azurerm_log_analytics_workspace.this.id

  tags = {
    environment = "dev"
    module      = "application-insights"
    example     = "basic"
  }
}

output "id" {
  value = module.application_insights.id
}

output "connection_string" {
  value     = module.application_insights.connection_string
  sensitive = true
}
