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
  name     = "rg-appi-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-appi-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "application_insights" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "appi-complete-dev-weu-001"
  workspace_id        = azurerm_log_analytics_workspace.this.id

  retention_in_days             = 120
  daily_data_cap_in_gb          = 5
  sampling_percentage           = 50
  local_authentication_disabled = true

  tags = {
    project     = "application-insights"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.application_insights.id
}

output "name" {
  value = module.application_insights.name
}
