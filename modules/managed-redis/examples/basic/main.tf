terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.54.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-managed-redis-basic-dev-weu-001"
  location = "westeurope"
}

module "managed_redis" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "amr-basic-dev-weu-001"
  sku_name            = "Balanced_B1"

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
  value = module.managed_redis.id
}

output "redis_hostname" {
  value = module.managed_redis.hostname
}

output "redis_port" {
  value = module.managed_redis.port
}
