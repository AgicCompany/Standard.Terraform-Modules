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
  name     = "rg-redis-example-dev-weu-001"
  location = "westeurope"
}

module "redis_cache" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "redis-example-dev-weu-001"
  sku_name            = "Basic"
  family              = "C"
  capacity            = 0

  enable_private_endpoint = false
  enable_public_access    = true

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "redis_id" {
  value = module.redis_cache.id
}

output "redis_hostname" {
  value = module.redis_cache.hostname
}

output "redis_ssl_port" {
  value = module.redis_cache.ssl_port
}
