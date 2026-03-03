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
  name     = "rg-appgw-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-appgw-complete-dev-weu-001"
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
  name                = "agw-complete-dev-weu-001"
  subnet_id           = azurerm_subnet.appgw.id

  sku_name = "Standard_v2"
  sku_tier = "Standard_v2"

  zones = ["1", "2", "3"]

  autoscale = {
    min_capacity = 2
    max_capacity = 10
  }

  enable_http2 = true

  # Two backend pools: web servers (IPs) and API servers (FQDNs)
  backend_address_pools = {
    web-servers = {
      ip_addresses = ["10.0.2.10", "10.0.2.11"]
    }
    api-servers = {
      fqdns = ["api.example.com", "api-backup.example.com"]
    }
  }

  # Two backend HTTP settings: web on port 80, API on port 443 with probe
  backend_http_settings = {
    web-http = {
      port     = 80
      protocol = "Http"
    }
    api-https = {
      port                                      = 443
      protocol                                  = "Https"
      probe_name                                = "api-health"
      request_timeout                           = 60
      pick_host_name_from_backend_http_settings = true
    }
  }

  # Health probe for API backend
  probes = {
    api-health = {
      protocol                                  = "Https"
      path                                      = "/health"
      interval                                  = 15
      timeout                                   = 10
      unhealthy_threshold                       = 2
      pick_host_name_from_backend_http_settings = true
      match_status_codes                        = ["200-299"]
    }
  }

  frontend_ports = {
    http = {
      port = 80
    }
    https = {
      port = 443
    }
  }

  # Two listeners: HTTP on port 80, host-filtered on port 443
  # NOTE: For HTTPS, add ssl_certificates and set ssl_certificate_name on the listener
  http_listeners = {
    http-listener = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
    api-listener = {
      frontend_port_name = "https"
      protocol           = "Http"
      host_name          = "api.example.com"
    }
  }

  # Two routing rules
  request_routing_rules = {
    web-rule = {
      priority                   = 100
      http_listener_name         = "http-listener"
      backend_address_pool_name  = "web-servers"
      backend_http_settings_name = "web-http"
    }
    api-rule = {
      priority                   = 200
      http_listener_name         = "api-listener"
      backend_address_pool_name  = "api-servers"
      backend_http_settings_name = "api-https"
    }
  }

  # Redirect configuration (for future use with SSL)
  redirect_configurations = {
    http-to-https = {
      redirect_type        = "Permanent"
      target_url           = "https://www.example.com"
      include_path         = true
      include_query_string = true
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "id" {
  value = module.application_gateway.id
}

output "name" {
  value = module.application_gateway.name
}

output "public_ip_address" {
  value = module.application_gateway.public_ip_address
}

output "backend_address_pool_ids" {
  value = module.application_gateway.backend_address_pool_ids
}
