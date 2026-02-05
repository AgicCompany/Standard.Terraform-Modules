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
  name     = "rg-st-complete-dev-weu-001"
  location = "westeurope"
}

# Virtual network for private endpoints
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

# Private DNS zones for all storage subresources
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# VNet links for all DNS zones
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "table" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "queue" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.queue.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Storage account with all four private endpoints
module "storage_full" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "stcompletedevweu001"

  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Enable all security features
  enable_versioning                    = true
  enable_blob_soft_delete              = true
  enable_container_soft_delete         = true
  blob_soft_delete_retention_days      = 30
  container_soft_delete_retention_days = 30

  # Enable all four private endpoints
  enable_blob_private_endpoint  = true
  enable_file_private_endpoint  = true
  enable_table_private_endpoint = true
  enable_queue_private_endpoint = true

  subnet_id = azurerm_subnet.private_endpoints.id
  private_dns_zone_ids = {
    blob  = azurerm_private_dns_zone.blob.id
    file  = azurerm_private_dns_zone.file.id
    table = azurerm_private_dns_zone.table.id
    queue = azurerm_private_dns_zone.queue.id
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.file,
    azurerm_private_dns_zone_virtual_network_link.table,
    azurerm_private_dns_zone_virtual_network_link.queue,
  ]
}

# Storage account with public access (for legacy scenarios)
module "storage_public" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "stpublicdevweu001"

  # Disable private endpoints, enable public access
  enable_private_endpoints = false
  enable_public_access     = true

  # Allow specific IPs/VNets
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"] # Example: office IP range
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "full_storage_account_id" {
  value = module.storage_full.id
}

output "full_primary_blob_endpoint" {
  value = module.storage_full.primary_blob_endpoint
}

output "full_private_endpoint_ids" {
  value = module.storage_full.private_endpoint_ids
}

output "full_private_ip_addresses" {
  value = module.storage_full.private_ip_addresses
}

output "public_storage_account_id" {
  value = module.storage_public.id
}
