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
  name     = "rg-aif-basic-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_storage_account" "this" {
  name                     = "staifbasicdev001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false
  shared_access_key_enabled     = true
  min_tls_version               = "TLS1_2"
}

resource "azurerm_key_vault" "this" {
  name                       = "kv-aif-basic-dev-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  rbac_authorization_enabled = true
}

module "ai_foundry" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aif-basic-dev-weu-001"

  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = azurerm_key_vault.this.id

  project_name = "aif-basic-proj"

  tags = {
    project     = "ai-foundry"
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "hub_id" {
  value = module.ai_foundry.id
}

output "project_id" {
  value = module.ai_foundry.project_id
}
