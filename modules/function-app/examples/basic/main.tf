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
  name     = "rg-func-example-dev-weu-001"
  location = "westeurope"
}

# Storage account (required by Azure Functions)
resource "azurerm_storage_account" "example" {
  name                     = "stfuncexampledevweu001"
  location                 = azurerm_resource_group.example.location
  resource_group_name      = azurerm_resource_group.example.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Consumption plan (Y1)
resource "azurerm_service_plan" "example" {
  name                = "asp-func-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Linux Function App with Python stack (no private endpoint, no App Insights)
module "function_app" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "func-example-dev-weu-001"
  service_plan_id     = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  application_stack = {
    python_version = "3.11"
  }

  enable_private_endpoint     = false
  enable_application_insights = false

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "function_app_id" {
  value = module.function_app.id
}

output "function_app_hostname" {
  value = module.function_app.default_hostname
}
