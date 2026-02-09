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
  name     = "rg-ca-example-dev-weu-001"
  location = "westeurope"
}

# Log Analytics workspace (required by Container Apps Environment)
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-ca-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Container Apps Environment (Consumption, external for simplicity)
resource "azurerm_container_app_environment" "example" {
  name                = "cae-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

# Container App with hello-world image and ingress
module "container_app" {
  source = "../../"

  resource_group_name          = azurerm_resource_group.example.name
  name                         = "ca-helloworld-dev-weu-001"
  container_app_environment_id = azurerm_container_app_environment.example.id

  container = {
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }

  enable_ingress          = true
  enable_external_ingress = true

  ingress = {
    target_port = 80
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "container_app_id" {
  value = module.container_app.id
}

output "container_app_fqdn" {
  value = module.container_app.latest_revision_fqdn
}
