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
  name     = "rg-ag-complete-dev-weu-001"
  location = "westeurope"
}

module "action_group" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  name                = "ag-complete-dev-weu-001"
  short_name          = "ag-complete"

  email_receivers = {
    platform-team = {
      email_address = "platform@company.com"
    }
    security-team = {
      email_address = "security@company.com"
    }
  }

  sms_receivers = {
    oncall-primary = {
      country_code = "1"
      phone_number = "5551234567"
    }
  }

  webhook_receivers = {
    pagerduty = {
      service_uri = "https://events.pagerduty.com/integration/example/enqueue"
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "action_group_id" {
  value = module.action_group.id
}

output "action_group_name" {
  value = module.action_group.name
}
