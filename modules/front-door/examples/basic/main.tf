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
  name     = "rg-frontdoor-example-dev-weu-001"
  location = "westeurope"
}

module "front_door" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  name                = "afd-example-dev-001"

  endpoints = {
    "web" = {}
  }

  origin_groups = {
    "web-origins" = {}
  }

  origins = {
    "web-app" = {
      origin_group_name = "web-origins"
      host_name         = "example-web-app.azurewebsites.net"
    }
  }

  routes = {
    "web-route" = {
      endpoint_name     = "web"
      origin_group_name = "web-origins"
    }
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "frontdoor_id" {
  value = module.front_door.id
}

output "endpoint_host_names" {
  value = module.front_door.endpoint_host_names
}
