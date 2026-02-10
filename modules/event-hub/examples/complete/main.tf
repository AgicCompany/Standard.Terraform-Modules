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
  name     = "rg-evh-complete-dev-weu-001"
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

# Private DNS zone for Event Hub
resource "azurerm_private_dns_zone" "eventhub" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "eventhub" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.eventhub.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Event Hub namespace with private endpoint and multiple event hubs
module "event_hub" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "evh-complete-dev-weu-001"

  sku                      = "Standard"
  auto_inflate_enabled     = true
  maximum_throughput_units = 10

  event_hubs = {
    events = {
      partition_count   = 4
      message_retention = 7
      consumer_groups = {
        analytics = { user_metadata = "Analytics processing" }
      }
    }
    telemetry = {
      partition_count   = 2
      message_retention = 1
    }
  }

  authorization_rules = {
    app-sender = {
      send = true
    }
  }

  # Private endpoint (default: enabled)
  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.private_endpoints.id
  private_dns_zone_id     = azurerm_private_dns_zone.eventhub.id

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.eventhub]
}

output "event_hub_namespace_id" {
  value = module.event_hub.id
}

output "eventhub_ids" {
  value = module.event_hub.eventhub_ids
}

output "consumer_group_ids" {
  value = module.event_hub.consumer_group_ids
}

output "private_endpoint_ip" {
  value = module.event_hub.private_ip_address
}
