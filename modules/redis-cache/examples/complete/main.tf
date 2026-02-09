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
  name     = "rg-redis-complete-dev-weu-001"
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

# Private DNS zone for Redis
resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.redis.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Redis Cache with Premium SKU, PE, zones, and custom config
module "redis_cache" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "redis-complete-dev-weu-001"
  sku_name            = "Premium"
  family              = "P"
  capacity            = 1

  # Redis configuration
  redis_configuration = {
    maxmemory_policy = "allkeys-lru"
  }

  # Patch schedule (Premium only)
  patch_schedule = {
    day_of_week    = "Saturday"
    start_hour_utc = 2
  }

  # Availability zones (Premium only)
  zones = ["1", "2", "3"]

  # Private endpoint (default: enabled)
  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.private_endpoints.id
  private_dns_zone_id     = azurerm_private_dns_zone.redis.id

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.redis]
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

output "private_endpoint_ip" {
  value = module.redis_cache.private_ip_address
}
