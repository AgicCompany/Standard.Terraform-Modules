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
  name     = "rg-servicebus-complete-dev-weu-001"
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

# Private DNS zone for Service Bus
resource "azurerm_private_dns_zone" "servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.servicebus.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Service Bus with Premium SKU, PE, queues, topics, and subscriptions
module "service_bus" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "sb-complete-dev-weu-001"
  sku                 = "Premium"
  capacity            = 1

  # Feature flags
  enable_local_auth = false

  # Private endpoint (default: enabled)
  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.private_endpoints.id
  private_dns_zone_id     = azurerm_private_dns_zone.servicebus.id

  queues = {
    "orders" = {
      max_delivery_count                   = 10
      dead_lettering_on_message_expiration = true
    }
    "notifications" = {
      max_size_in_megabytes = 2048
      requires_session      = true
    }
  }

  topics = {
    "events" = {
      max_size_in_megabytes = 2048
      subscriptions = {
        "audit-log" = {
          max_delivery_count                   = 5
          dead_lettering_on_message_expiration = true
        }
        "analytics" = {
          max_delivery_count = 3
        }
      }
    }
    "commands" = {
      subscriptions = {
        "processor" = {
          lock_duration      = "PT1M"
          max_delivery_count = 10
        }
      }
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.servicebus]
}

output "namespace_id" {
  value = module.service_bus.id
}

output "namespace_endpoint" {
  value = module.service_bus.endpoint
}

output "private_endpoint_ip" {
  value = module.service_bus.private_ip_address
}

output "queue_ids" {
  value = module.service_bus.queue_ids
}

output "topic_ids" {
  value = module.service_bus.topic_ids
}
