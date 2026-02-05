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
  name     = "rg-kv-example-dev-weu-001"
  location = "westeurope"
}

# Virtual network for private endpoint
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-dev-weu-001"
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

# Private DNS zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

module "key_vault" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "kv-example-dev-weu-001"

  subnet_id           = azurerm_subnet.private_endpoints.id
  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.keyvault]
}

output "vault_id" {
  value = module.key_vault.id
}

output "vault_uri" {
  value = module.key_vault.vault_uri
}
