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
  name     = "rg-appgw-example-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-appgw-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "application_gateway" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "agw-example-dev-weu-001"
  subnet_id           = azurerm_subnet.appgw.id

  backend_address_pools = {
    web-backend = {
      fqdns = ["example.com"]
    }
  }

  backend_http_settings = {
    web-http = {
      port     = 80
      protocol = "Http"
    }
  }

  frontend_ports = {
    http = {
      port = 80
    }
  }

  http_listeners = {
    http-listener = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
  }

  request_routing_rules = {
    web-rule = {
      priority                   = 100
      http_listener_name         = "http-listener"
      backend_address_pool_name  = "web-backend"
      backend_http_settings_name = "web-http"
    }
  }

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.application_gateway.id
}

output "public_ip_address" {
  value = module.application_gateway.public_ip_address
}
