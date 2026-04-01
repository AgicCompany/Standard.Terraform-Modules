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
  name     = "rg-managed-redis-complete-dev-weu-001"
  location = "westeurope"
}

# Virtual network for private endpoint
resource "azurerm_virtual_network" "example" {
  name                = "vnet-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = "snet-private-endpoints"
  resource_group_name               = azurerm_resource_group.example.name
  virtual_network_name              = azurerm_virtual_network.example.name
  address_prefixes                  = ["10.0.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# Private DNS zone for Azure Managed Redis
resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.redis.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Managed Redis with PE, RedisJSON, RDB persistence, and custom eviction
module "managed_redis" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "amr-complete-dev-weu-001"
  sku_name            = "MemoryOptimized_M10"

  # Database configuration
  eviction_policy = "AllKeysLRU"
  modules = [
    { name = "RedisJSON" }
  ]

  # RDB persistence
  persistence_rdb_frequency = "12h"

  # Private endpoint (default: enabled)
  subnet_id           = azurerm_subnet.private_endpoints.id
  private_dns_zone_id = azurerm_private_dns_zone.redis.id

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.redis]
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

output "private_endpoint_ip" {
  value = module.managed_redis.private_ip_address
}
