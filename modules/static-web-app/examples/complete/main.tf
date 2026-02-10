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
  name     = "rg-stapp-complete-dev-weu-001"
  location = "westeurope"
}

module "static_web_app" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "stapp-complete-dev-weu-001"

  sku_tier = "Standard"
  sku_size = "Standard"

  app_settings = {
    API_URL      = "https://api.example.com"
    FEATURE_FLAG = "true"
  }

  preview_environments_enabled = true

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.static_web_app.id
}

output "default_host_name" {
  value = module.static_web_app.default_host_name
}

output "name" {
  value = module.static_web_app.name
}
