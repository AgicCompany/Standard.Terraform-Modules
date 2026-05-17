terraform {
  required_version = ">= 1.10.0"

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
  name     = "rg-acsmail-basic-dev-weu-001"
  location = "westeurope"
}

module "acs_email" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "acs-mail-basic-dev-weu-001"
  data_location       = "Europe"

  tags = {
    project     = "acs-email"
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "from_address" {
  value = module.acs_email.mail_from_sender_domain
}
