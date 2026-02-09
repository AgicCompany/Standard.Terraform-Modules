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

# --- Resource Group ---

resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-webapp-weu-001"
  location = "westeurope"
}

# --- Module 1: Virtual Network ---

module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-webapp-weu-001"
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

# --- Module 2: Private DNS Zone ---

module "private_dns_zone" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.azurewebsites.net"

  virtual_network_links = {
    vnet-webapp = {
      virtual_network_id    = module.virtual_network.id
      registration_enabled  = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# --- Module 3: Log Analytics Workspace ---

module "log_analytics" {
  source = "../../../modules/log-analytics-workspace"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "law-tftest-webapp-weu-001"

  tags = { environment = "test", project = "tftest" }
}

# --- Module 4: App Service Plan ---

module "app_service_plan" {
  source = "../../../modules/app-service-plan"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "asp-tftest-webapp-weu-001"
  sku_name            = "B1"

  tags = { environment = "test", project = "tftest" }
}

# --- Module 5: Linux Web App (with PE + VNet integration) ---

module "web_app" {
  source = "../../../modules/linux-web-app"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "app-tftest-webapp-weu-001"
  service_plan_id     = module.app_service_plan.id

  application_stack = {
    dotnet_version = "8.0"
  }

  # Private endpoint
  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.private_dns_zone.id

  # VNet integration (outbound)
  enable_vnet_integration    = true
  vnet_integration_subnet_id = module.virtual_network.subnet_ids["snet-integration"]

  tags = { environment = "test", project = "tftest" }
}

# --- Module 6: Diagnostic Settings (attached to web app) ---

module "diagnostic_settings" {
  source = "../../../modules/diagnostic-settings"

  name                       = "diag-tftest-webapp-weu-001"
  target_resource_id         = module.web_app.id
  log_analytics_workspace_id = module.log_analytics.id
}

# --- Outputs ---

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "web_app_id" {
  value = module.web_app.id
}

output "web_app_default_hostname" {
  value = module.web_app.default_hostname
}

output "web_app_private_ip" {
  value = module.web_app.private_ip_address
}

output "diagnostic_settings_id" {
  value = module.diagnostic_settings.id
}
