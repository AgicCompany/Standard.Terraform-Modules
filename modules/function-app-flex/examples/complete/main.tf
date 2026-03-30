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
  name     = "rg-funcflex-complete-example"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-funcflex-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "outbound" {
  name                 = "snet-outbound"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}

resource "azurerm_subnet" "pe" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "funcflex-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-funcflex-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stfuncflexcmplex"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name               = "app-package"
  storage_account_id = azurerm_storage_account.example.id
}

resource "azurerm_service_plan" "example" {
  name                = "asp-funcflex-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "FC1"
}

module "function_app_flex" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "func-flex-complete-example"

  service_plan_id            = azurerm_service_plan.example.id
  runtime_name               = "dotnet-isolated"
  runtime_version            = "8.0"
  storage_container_endpoint = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}"

  instance_memory_in_mb  = 2048
  maximum_instance_count = 20

  storage_authentication_type       = "UserAssignedIdentity"
  storage_user_assigned_identity_id = azurerm_user_assigned_identity.example.id

  always_ready_instances = {
    "MyFunction" = {
      instance_count = 1
    }
  }

  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.example.id]

  virtual_network_subnet_id = azurerm_subnet.outbound.id

  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.pe.id
  private_dns_zone_ids       = [azurerm_private_dns_zone.example.id]

  tags = {
    environment = "example"
  }
}
