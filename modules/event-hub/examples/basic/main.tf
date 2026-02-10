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
  name     = "rg-evh-example-dev-weu-001"
  location = "westeurope"
}

module "event_hub" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "evh-example-dev-weu-001"

  sku = "Standard"

  enable_private_endpoint = false
  enable_public_access    = true
  enable_local_auth       = true

  event_hubs = {
    events = {
      partition_count   = 2
      message_retention = 1
    }
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "event_hub_namespace_id" {
  value = module.event_hub.id
}
