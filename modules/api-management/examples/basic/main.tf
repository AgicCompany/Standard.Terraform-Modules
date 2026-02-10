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
  name     = "rg-apim-example-dev-weu-001"
  location = "westeurope"
}

# API Management with Developer SKU (no private endpoint)
module "apim" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "apim-example-dev-weu-001"
  publisher_name      = "Example Corp"
  publisher_email     = "admin@example.com"

  sku_name = "Developer_1"

  enable_private_endpoint = false
  enable_public_access    = true

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "apim_id" {
  value = module.apim.id
}

output "apim_gateway_url" {
  value = module.apim.gateway_url
}
