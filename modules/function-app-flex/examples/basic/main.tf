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
  name     = "rg-funcflex-basic-example"
  location = "westeurope"
}

resource "azurerm_storage_account" "example" {
  name                     = "stfuncflexbasicex"
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
  name                = "asp-funcflex-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "FC1"
}

module "function_app_flex" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "func-flex-basic-example"

  service_plan_id            = azurerm_service_plan.example.id
  runtime_name               = "python"
  runtime_version            = "3.11"
  storage_container_endpoint = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}"

  enable_private_endpoint = false

  tags = {
    environment = "example"
  }
}
