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
  name     = "rg-frontdoor-complete-dev-weu-001"
  location = "westeurope"
}

# Front Door with multiple endpoints, origin groups, origins, and routes
module "front_door" {
  source = "../../"

  resource_group_name      = azurerm_resource_group.example.name
  name                     = "afd-complete-dev-001"
  response_timeout_seconds = 120

  endpoints = {
    "web" = {}
    "api" = {}
  }

  origin_groups = {
    "web-origins" = {
      health_probe = {
        path                = "/health"
        protocol            = "Https"
        interval_in_seconds = 60
        request_type        = "GET"
      }
      load_balancing = {
        sample_size                 = 4
        successful_samples_required = 2
      }
    }
    "api-origins" = {
      health_probe = {
        path     = "/api/health"
        protocol = "Https"
      }
    }
  }

  origins = {
    "web-primary" = {
      origin_group_name = "web-origins"
      host_name         = "app-web-dev-weu-001.azurewebsites.net"
      priority          = 1
      weight            = 1000
    }
    "web-secondary" = {
      origin_group_name = "web-origins"
      host_name         = "app-web-dev-neu-001.azurewebsites.net"
      priority          = 2
      weight            = 500
    }
    "api-app" = {
      origin_group_name = "api-origins"
      host_name         = "app-api-dev-weu-001.azurewebsites.net"
    }
  }

  routes = {
    "web-route" = {
      endpoint_name     = "web"
      origin_group_name = "web-origins"
      origin_names      = ["web-primary", "web-secondary"]
      patterns_to_match = ["/*"]
    }
    "api-route" = {
      endpoint_name       = "api"
      origin_group_name   = "api-origins"
      origin_names        = ["api-app"]
      patterns_to_match   = ["/api/*"]
      forwarding_protocol = "HttpsOnly"
    }
  }

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "frontdoor_id" {
  value = module.front_door.id
}

output "endpoint_host_names" {
  value = module.front_door.endpoint_host_names
}

output "origin_group_ids" {
  value = module.front_door.origin_group_ids
}

output "route_ids" {
  value = module.front_door.route_ids
}
