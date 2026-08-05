terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-aif-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "this" {
  name                          = "staifcompletedev001"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
  shared_access_key_enabled     = true
  min_tls_version               = "TLS1_2"
}

resource "azurerm_key_vault" "this" {
  name                       = "kv-aif-complete-dev-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
}

resource "azurerm_application_insights" "this" {
  name                = "appi-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
}

resource "azurerm_container_registry" "this" {
  name                = "craifcompletedev001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "uami-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_role_assignment" "uami_kv_crypto" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_key_vault_key" "cmk" {
  name         = "aif-cmk"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.uami_kv_crypto]
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "pe" {
  name                              = "snet-pe"
  resource_group_name               = azurerm_resource_group.example.name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = ["10.20.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_private_dns_zone" "api" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "notebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "api" {
  name                  = "vnet-link-api"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.api.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "notebooks" {
  name                  = "vnet-link-notebooks"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.notebooks.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

module "ai_foundry" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aif-complete-dev-weu-001"

  storage_account_id      = azurerm_storage_account.this.id
  key_vault_id            = azurerm_key_vault.this.id
  application_insights_id = azurerm_application_insights.this.id
  container_registry_id   = azurerm_container_registry.this.id

  project_name = "aif-complete-proj"

  identity_type                  = "SystemAssigned, UserAssigned"
  identity_ids                   = [azurerm_user_assigned_identity.this.id]
  primary_user_assigned_identity = azurerm_user_assigned_identity.this.id

  encryption = {
    key_id                    = azurerm_key_vault_key.cmk.versionless_id
    key_vault_id              = azurerm_key_vault.this.id
    user_assigned_identity_id = azurerm_user_assigned_identity.this.id
  }

  managed_network_isolation_mode = "AllowOnlyApprovedOutbound"
  high_business_impact_enabled   = true

  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.pe.id
  private_dns_zone_ids = [
    azurerm_private_dns_zone.api.id,
    azurerm_private_dns_zone.notebooks.id,
  ]

  diagnostic_settings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  tags = {
    project     = "ai-foundry"
    environment = "dev"
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.api,
    azurerm_private_dns_zone_virtual_network_link.notebooks,
    azurerm_key_vault_key.cmk,
  ]
}

output "hub_id" {
  value = module.ai_foundry.id
}

output "project_id" {
  value = module.ai_foundry.project_id
}

output "private_endpoint_ip" {
  value = module.ai_foundry.private_endpoint_ip_address
}
