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
  name     = "rg-acsmail-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-acsmail-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "acs_email" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "acs-mail-complete-dev-weu-001"
  data_location       = "Europe"

  enable_custom_domain             = true
  domain_name                      = "mail.example.com"
  user_engagement_tracking_enabled = true

  sender_usernames = {
    no_reply = {
      username     = "no-reply"
      display_name = "Do Not Reply"
    }
    notifications = {
      username     = "notifications"
      display_name = "Notifications"
    }
  }

  diagnostic_settings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  tags = {
    project     = "acs-email"
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "verification_records" {
  value       = module.acs_email.verification_records
  description = "Provision these at your DNS registrar to complete domain verification"
}

output "sender_addresses" {
  value = {
    for k, s in module.acs_email.sender_usernames : k => s.from_address
  }
}
