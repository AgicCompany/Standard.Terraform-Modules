############################################
# Integration Test: Serverless Stack
# Covers: function-app, storage-account,
#          key-vault, application-insights,
#          user-assigned-identity, action-group
############################################

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

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-serverless-weu-001"
  location = "westeurope"
  tags     = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-serverless-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-pe = {
      address_prefixes                  = ["10.0.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
    snet-integration = {
      address_prefixes = ["10.0.2.0/24"]
      delegation = {
        name = "webapp"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Private DNS Zones
# -----------------------------------------------------------------------------
module "dns_web" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.azurewebsites.net"

  virtual_network_links = {
    serverless-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

module "dns_vault" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.vaultcore.azure.net"

  virtual_network_links = {
    serverless-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

module "dns_blob" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.blob.core.windows.net"

  virtual_network_links = {
    serverless-vnet = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Log Analytics Workspace
# -----------------------------------------------------------------------------
module "log_analytics" {
  source = "../../../modules/log-analytics-workspace"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "law-tftest-serverless-weu-001"

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Application Insights
# -----------------------------------------------------------------------------
module "application_insights" {
  source = "../../../modules/application-insights"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "appi-tftest-serverless-weu-001"
  workspace_id        = module.log_analytics.id

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# User Assigned Identity
# -----------------------------------------------------------------------------
module "user_identity" {
  source = "../../../modules/user-assigned-identity"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "id-tftest-serverless-weu-001"

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Storage Account (for Function App runtime)
# -----------------------------------------------------------------------------
module "storage_account" {
  source = "../../../modules/storage-account"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "sttftestslsweu001"

  shared_access_key_enabled    = true # Required for function app access key pattern
  enable_private_endpoints     = true
  enable_blob_private_endpoint = true
  subnet_id                    = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_ids = {
    blob = module.dns_blob.id
  }

  tags = { environment = "test", project = "tftest" }
}

# Retrieve access key for function app (module doesn't expose it by design)
data "azurerm_storage_account" "this" {
  name                = module.storage_account.name
  resource_group_name = azurerm_resource_group.this.name
}

# -----------------------------------------------------------------------------
# App Service Plan
# -----------------------------------------------------------------------------
module "app_service_plan" {
  source = "../../../modules/app-service-plan"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "asp-tftest-serverless-weu-001"
  sku_name            = "B1"

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Function App
# -----------------------------------------------------------------------------
module "function_app" {
  source = "../../../modules/function-app"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "func-tftest-serverless-weu-001"

  service_plan_id            = module.app_service_plan.id
  storage_account_name       = module.storage_account.name
  storage_account_access_key = data.azurerm_storage_account.this.primary_access_key

  application_stack = {
    node_version = "20"
  }

  enable_private_endpoint                = true
  subnet_id                              = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id                    = module.dns_web.id
  enable_vnet_integration                = true
  vnet_integration_subnet_id             = module.virtual_network.subnet_ids["snet-integration"]
  enable_system_assigned_identity        = true
  enable_application_insights            = true
  application_insights_connection_string = module.application_insights.connection_string

  user_assigned_identity_ids = [module.user_identity.id]

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
module "key_vault" {
  source = "../../../modules/key-vault"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "kv-tftest-sls-weu-001"

  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.dns_vault.id

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Action Group
# -----------------------------------------------------------------------------
module "action_group" {
  source = "../../../modules/action-group"

  resource_group_name = azurerm_resource_group.this.name
  name                = "ag-tftest-serverless-weu-001"
  short_name          = "tftest-sls"

  email_receivers = {
    test-admin = {
      email_address = "test@example.com"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "function_app_id" {
  value = module.function_app.id
}

output "function_app_default_hostname" {
  value = module.function_app.default_hostname
}

output "function_app_principal_id" {
  value = module.function_app.principal_id
}

output "function_app_private_ip" {
  value = module.function_app.private_ip_address
}

output "key_vault_id" {
  value = module.key_vault.id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "key_vault_private_ip" {
  value = module.key_vault.private_ip_address
}

output "application_insights_id" {
  value = module.application_insights.id
}

output "user_identity_id" {
  value = module.user_identity.id
}

output "user_identity_principal_id" {
  value = module.user_identity.principal_id
}

output "action_group_id" {
  value = module.action_group.id
}
