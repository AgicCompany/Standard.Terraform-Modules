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
  name     = "rg-dns-complete-dev-weu-001"
  location = "westeurope"
}

# Hub virtual network
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Spoke virtual network
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.1.0.0/16"]
}

# Blob storage DNS zone linked to both VNets
module "dns_blob" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  name                = "privatelink.blob.core.windows.net"

  virtual_network_links = {
    hub-link = {
      virtual_network_id   = azurerm_virtual_network.hub.id
      registration_enabled = false
    }
    spoke-link = {
      virtual_network_id   = azurerm_virtual_network.spoke.id
      registration_enabled = false
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

# Key Vault DNS zone linked to both VNets
module "dns_keyvault" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  name                = "privatelink.vaultcore.azure.net"

  virtual_network_links = {
    hub-link = {
      virtual_network_id   = azurerm_virtual_network.hub.id
      registration_enabled = false
    }
    spoke-link = {
      virtual_network_id   = azurerm_virtual_network.spoke.id
      registration_enabled = false
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "blob_zone_id" {
  value = module.dns_blob.id
}

output "blob_vnet_link_ids" {
  value = module.dns_blob.virtual_network_link_ids
}

output "keyvault_zone_id" {
  value = module.dns_keyvault.id
}

output "keyvault_vnet_link_ids" {
  value = module.dns_keyvault.virtual_network_link_ids
}
