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

resource "azurerm_resource_group" "this" {
  name     = "rg-natgw-complete-dev-weu-001"
  location = "westeurope"
}

module "nat_gateway" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "natgw-complete-dev-weu-001"

  zones                   = ["1"]
  idle_timeout_in_minutes = 10

  tags = {
    Environment = "dev"
    Project     = "infrastructure"
    Terraform   = "true"
  }
}

output "nat_gateway_id" {
  value = module.nat_gateway.id
}

output "nat_gateway_name" {
  value = module.nat_gateway.name
}

output "public_ip_address" {
  value = module.nat_gateway.public_ip_address
}

output "public_ip_id" {
  value = module.nat_gateway.public_ip_id
}

output "resource_guid" {
  value = module.nat_gateway.resource_guid
}
