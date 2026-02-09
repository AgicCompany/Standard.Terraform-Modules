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
  name     = "rg-webapp-example-dev-weu-001"
  location = "westeurope"
}

# App Service Plan
resource "azurerm_service_plan" "example" {
  name                = "asp-webapp-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Linux Web App with .NET stack (no private endpoint)
module "web_app" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "app-example-dev-weu-001"
  service_plan_id     = azurerm_service_plan.example.id

  application_stack = {
    dotnet_version = "8.0"
  }

  enable_private_endpoint = false

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "web_app_id" {
  value = module.web_app.id
}

output "web_app_hostname" {
  value = module.web_app.default_hostname
}
