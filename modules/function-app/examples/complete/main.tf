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
  name     = "rg-func-complete-dev-weu-001"
  location = "westeurope"
}

# Virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for private endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                              = "snet-private-endpoints"
  resource_group_name               = azurerm_resource_group.example.name
  virtual_network_name              = azurerm_virtual_network.example.name
  address_prefixes                  = ["10.0.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

# Subnet for VNet integration
resource "azurerm_subnet" "vnet_integration" {
  name                 = "snet-vnet-integration"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "functionapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Private DNS zone for function apps
resource "azurerm_private_dns_zone" "webapps" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "webapps" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.webapps.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Storage account (required by Azure Functions)
resource "azurerm_storage_account" "example" {
  name                     = "stfunccompletedevweu001"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Premium plan (supports VNet integration)
resource "azurerm_service_plan" "example" {
  name                = "asp-func-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "P1v3"
}

# Application Insights
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-func-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "appi-func-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "other"
}

# Linux Function App with all features
module "function_app" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "func-complete-dev-weu-001"
  service_plan_id     = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  # .NET application stack (isolated runtime)
  application_stack = {
    dotnet_version              = "8.0"
    use_dotnet_isolated_runtime = true
  }

  # Application settings
  app_settings = {
    "ENVIRONMENT" = "dev"
    "LOG_LEVEL"   = "Information"
  }

  # Application Insights
  enable_application_insights            = true
  application_insights_connection_string = azurerm_application_insights.example.connection_string

  # VNet integration (outbound)
  enable_vnet_integration    = true
  vnet_integration_subnet_id = azurerm_subnet.vnet_integration.id

  # Identity
  enable_system_assigned_identity = true

  # Private endpoint (inbound)
  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.private_endpoints.id
  private_dns_zone_id     = azurerm_private_dns_zone.webapps.id

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.webapps]
}

output "function_app_id" {
  value = module.function_app.id
}

output "function_app_hostname" {
  value = module.function_app.default_hostname
}

output "function_app_principal_id" {
  value = module.function_app.principal_id
}

output "private_endpoint_ip" {
  value = module.function_app.private_ip_address
}
