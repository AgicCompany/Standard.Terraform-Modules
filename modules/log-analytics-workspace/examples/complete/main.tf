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
  name     = "rg-log-complete-dev-weu-001"
  location = "westeurope"
}

module "log_analytics" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "log-complete-dev-weu-001"

  sku               = "PerGB2018"
  retention_in_days = 90
  daily_quota_gb    = 5

  # Enable internet access for development/testing
  enable_internet_ingestion = true
  enable_internet_query     = true

  tags = {
    project     = "complete-example"
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

output "workspace_name" {
  value = module.log_analytics.name
}
