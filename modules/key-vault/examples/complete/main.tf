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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-complete-dev-weu-001"
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

# Key Vault with private endpoint (default secure configuration)
module "key_vault_private" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "kv-private-dev-weu-001"

  sku_name                   = "standard"
  soft_delete_retention_days = 30

  # VM integration flags (all disabled by default)
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true

  # Private endpoint (default: enabled)
  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.private_endpoints.id
  private_dns_zone_id     = azurerm_private_dns_zone.keyvault.id

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.keyvault]
}

# Key Vault with public access (for legacy/testing scenarios)
module "key_vault_public" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "kv-public-dev-weu-001"

  # Disable purge protection for ephemeral test environments
  enable_purge_protection    = false
  soft_delete_retention_days = 7

  # Public access with network ACLs
  enable_private_endpoint = false
  enable_public_access    = true

  network_acls = {
    bypass         = "AzureServices"
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

# Role assignment example: grant current user Key Vault Administrator role
resource "azurerm_role_assignment" "kv_admin_private" {
  scope                = module.key_vault_private.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_admin_public" {
  scope                = module.key_vault_public.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

output "private_vault_id" {
  value = module.key_vault_private.id
}

output "private_vault_uri" {
  value = module.key_vault_private.vault_uri
}

output "private_endpoint_ip" {
  value = module.key_vault_private.private_ip_address
}

output "public_vault_id" {
  value = module.key_vault_public.id
}

output "public_vault_uri" {
  value = module.key_vault_public.vault_uri
}
