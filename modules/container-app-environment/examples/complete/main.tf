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
  name     = "rg-cae-complete-dev-weu-001"
  location = "westeurope"
}

# Log Analytics workspace (required dependency)
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-cae-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Virtual network for VNet integration
resource "azurerm_virtual_network" "example" {
  name                = "vnet-cae-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cae" {
  name                 = "snet-cae"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/21"]

  delegation {
    name = "container-apps"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Container Apps Environment with workload profiles and zone redundancy
module "container_app_environment" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "cae-complete-dev-weu-001"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  infrastructure_subnet_id   = azurerm_subnet.cae.id

  # Internal load balancer (default: true)
  enable_internal_load_balancer = true

  # Zone redundancy (create-time setting, cannot be changed later)
  enable_zone_redundancy = true

  # Dedicated workload profiles
  workload_profiles = {
    "dedicated-d4" = {
      workload_profile_type = "D4"
      minimum_count         = 1
      maximum_count         = 3
    }
    "dedicated-e4" = {
      workload_profile_type = "E4"
      minimum_count         = 0
      maximum_count         = 2
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "cae_id" {
  value = module.container_app_environment.id
}

output "cae_default_domain" {
  value = module.container_app_environment.default_domain
}

output "cae_static_ip" {
  value = module.container_app_environment.static_ip_address
}

output "cae_platform_reserved_cidr" {
  value = module.container_app_environment.platform_reserved_cidr
}
