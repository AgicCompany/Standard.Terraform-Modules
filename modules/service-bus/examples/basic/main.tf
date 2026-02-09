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
  name     = "rg-servicebus-example-dev-weu-001"
  location = "westeurope"
}

module "service_bus" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "sb-example-dev-weu-001"
  sku                 = "Standard"

  enable_private_endpoint = false
  enable_local_auth       = true

  queues = {
    "orders" = {
      max_delivery_count = 5
    }
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "namespace_id" {
  value = module.service_bus.id
}

output "namespace_endpoint" {
  value = module.service_bus.endpoint
}
