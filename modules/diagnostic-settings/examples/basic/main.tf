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
  name     = "rg-diag-example-dev-weu-001"
  location = "westeurope"
}

# Log Analytics workspace as the diagnostic destination
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-diag-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Key Vault as the target resource to monitor
resource "azurerm_key_vault" "example" {
  name                          = "kv-diagex-dev-weu-001"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = true
}

# Send all logs and metrics from Key Vault to Log Analytics
module "diag" {
  source = "../../"

  name                       = "diag-kv-example-dev-weu-001"
  target_resource_id         = azurerm_key_vault.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

output "diagnostic_setting_id" {
  value = module.diag.id
}
