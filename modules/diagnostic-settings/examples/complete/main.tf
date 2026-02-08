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
  name     = "rg-diag-complete-dev-weu-001"
  location = "westeurope"
}

# Log Analytics workspace as the diagnostic destination
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-diag-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Key Vault as a target resource
resource "azurerm_key_vault" "example" {
  name                          = "kv-diagcm-dev-weu-001"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = true
}

# Second Key Vault as another target resource
resource "azurerm_key_vault" "example2" {
  name                          = "kv-diagcm-dev-weu-002"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = true
}

# Key Vault diagnostics with selective categories and dedicated tables
module "diag_keyvault_selective" {
  source = "../../"

  name                       = "diag-kv-selective-dev-weu-001"
  target_resource_id         = azurerm_key_vault.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  enabled_log_categories         = ["AuditEvent", "AzurePolicyEvaluationDetails"]
  metric_categories              = ["AllMetrics"]
  log_analytics_destination_type = "Dedicated"
}

# Key Vault diagnostics with all categories (default)
module "diag_keyvault_all" {
  source = "../../"

  name                       = "diag-kv-all-dev-weu-001"
  target_resource_id         = azurerm_key_vault.example2.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  log_analytics_destination_type = "Dedicated"
}

output "keyvault_selective_diag_id" {
  value = module.diag_keyvault_selective.id
}

output "keyvault_all_diag_id" {
  value = module.diag_keyvault_all.id
}
