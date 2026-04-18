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
  name     = "rg-stapp-example-dev-weu-001"
  location = "westeurope"
}

module "static_web_app" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "stapp-example-dev-weu-001"

  # Free SKU: no private endpoint support. Override secure defaults explicitly.
  sku_tier                = "Free"
  sku_size                = "Free"
  enable_private_endpoint = false
  enable_public_access    = true

  tags = {
    project     = "example"
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
