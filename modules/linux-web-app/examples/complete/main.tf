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
  name     = "rg-webapp-complete-dev-weu-001"
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
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Private DNS zone for web apps
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

# App Service Plan (Premium for VNet integration)
resource "azurerm_service_plan" "example" {
  name                = "asp-webapp-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "P1v3"
}

# User-assigned managed identity
resource "azurerm_user_assigned_identity" "example" {
  name                = "id-webapp-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Linux Web App with all features
module "web_app" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "app-complete-dev-weu-001"
  service_plan_id     = azurerm_service_plan.example.id

  # Docker application stack
  application_stack = {
    docker_image_name   = "nginx:latest"
    docker_registry_url = "https://index.docker.io"
  }

  # Application settings
  app_settings = {
    "ENVIRONMENT"    = "dev"
    "LOG_LEVEL"      = "Information"
    "ENABLE_SWAGGER" = "true"
  }

  # Connection strings
  connection_strings = {
    "Database" = {
      type  = "SQLAzure"
      value = "Server=tcp:sql-example.database.windows.net;Database=mydb;"
    }
  }

  # Health check
  health_check_path = "/health"
  always_on         = true

  # VNet integration (outbound)
  enable_vnet_integration    = true
  vnet_integration_subnet_id = azurerm_subnet.vnet_integration.id

  # Identity
  enable_system_assigned_identity = true
  user_assigned_identity_ids      = [azurerm_user_assigned_identity.example.id]

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

output "web_app_id" {
  value = module.web_app.id
}

output "web_app_hostname" {
  value = module.web_app.default_hostname
}

output "web_app_principal_id" {
  value = module.web_app.principal_id
}

output "private_endpoint_ip" {
  value = module.web_app.private_ip_address
}
