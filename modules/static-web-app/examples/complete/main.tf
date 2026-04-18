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
  name     = "rg-stapp-complete-dev-weu-001"
  location = "westeurope"
}

# --- Networking ---

resource "azurerm_virtual_network" "this" {
  name                = "vnet-stapp-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "pe" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "stapp" {
  name                = "privatelink.azurestaticapps.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "stapp" {
  name                  = "stapp-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.stapp.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# --- Static Web App ---

module "static_web_app" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "stapp-complete-dev-weu-001"

  app_settings = {
    API_URL      = "https://api.example.com"
    FEATURE_FLAG = "true"
  }

  preview_environments_enabled = true

  # Private endpoint (Standard SKU + PE disabled public access are secure defaults)
  subnet_id           = azurerm_subnet.pe.id
  private_dns_zone_id = azurerm_private_dns_zone.stapp.id

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.static_web_app.id
}

output "default_host_name" {
  value = module.static_web_app.default_host_name
}

output "name" {
  value = module.static_web_app.name
}

output "private_endpoint_id" {
  value = module.static_web_app.private_endpoint_id
}

output "private_ip_address" {
  value = module.static_web_app.private_ip_address
}
