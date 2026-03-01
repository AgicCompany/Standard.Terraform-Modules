############################################
# Integration Test: Messaging Stack
# Covers: event-hub, service-bus,
#          cosmosdb, redis-cache
############################################

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

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-messaging-weu-001"
  location = "westeurope"
  tags     = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-messaging-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-pe = {
      address_prefixes                  = ["10.0.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Private DNS Zones
# Event Hub and Service Bus share the same DNS zone
# -----------------------------------------------------------------------------
module "dns_servicebus" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.servicebus.windows.net"

  virtual_network_links = {
    messaging-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

module "dns_cosmosdb" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.documents.azure.com"

  virtual_network_links = {
    messaging-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

module "dns_redis" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.redis.cache.windows.net"

  virtual_network_links = {
    messaging-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Event Hub
# -----------------------------------------------------------------------------
module "event_hub" {
  source = "../../../modules/event-hub"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "evhns-tftest-messaging-weu-001"

  sku      = "Standard"
  capacity = 1

  event_hubs = {
    evh-orders = {
      partition_count   = 2
      message_retention = 1
      consumer_groups = {
        cg-processor = {}
      }
    }
  }

  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.dns_servicebus.id

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Service Bus
# -----------------------------------------------------------------------------
module "service_bus" {
  source = "../../../modules/service-bus"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "sb-tftest-messaging-weu-001"

  sku      = "Premium"
  capacity = 1

  queues = {
    sbq-commands = {
      max_delivery_count = 10
    }
  }

  topics = {
    sbt-events = {
      subscriptions = {
        sbs-handler = {
          max_delivery_count = 10
        }
      }
    }
  }

  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.dns_servicebus.id

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Cosmos DB
# -----------------------------------------------------------------------------
module "cosmosdb" {
  source = "../../../modules/cosmosdb"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "cosmos-tftest-messaging-weu-001"

  consistency_policy = {
    consistency_level = "Session"
  }

  geo_locations = [{
    location          = "northeurope"
    failover_priority = 0
    zone_redundant    = false
  }]

  sql_databases = {
    testdb = {}
  }

  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.dns_cosmosdb.id

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Redis Cache
# -----------------------------------------------------------------------------
module "redis_cache" {
  source = "../../../modules/redis-cache"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "redis-tftest-messaging-weu-001"

  sku_name = "Standard"
  family   = "C"
  capacity = 0

  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.dns_redis.id

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "event_hub_namespace_id" {
  value = module.event_hub.id
}

output "event_hub_private_ip" {
  value = module.event_hub.private_ip_address
}

output "service_bus_id" {
  value = module.service_bus.id
}

output "service_bus_endpoint" {
  value = module.service_bus.endpoint
}

output "service_bus_private_ip" {
  value = module.service_bus.private_ip_address
}

output "cosmosdb_id" {
  value = module.cosmosdb.id
}

output "cosmosdb_endpoint" {
  value = module.cosmosdb.endpoint
}

output "cosmosdb_private_ip" {
  value = module.cosmosdb.private_ip_address
}

output "redis_cache_id" {
  value = module.redis_cache.id
}

output "redis_cache_hostname" {
  value = module.redis_cache.hostname
}

output "redis_cache_private_ip" {
  value = module.redis_cache.private_ip_address
}
