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

# Front Door Premium with WAF, custom domains, rule sets, and Private Link origins
module "front_door" {
  source = "../../"

  resource_group_name      = azurerm_resource_group.example.name
  name                     = "afd-complete-dev-001"
  sku_name                 = "Premium_AzureFrontDoor"
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

  custom_domains = {
    "www" = {
      hostname         = "www.example.com"
      certificate_type = "ManagedCertificate"
    }
    "api" = {
      hostname         = "api.example.com"
      certificate_type = "ManagedCertificate"
    }
  }

  waf = {
    name = "wafpolicycompleteddev001"
    mode = "Prevention"
    managed_rules = [
      {
        type    = "DefaultRuleSet"
        version = "1.0"
        action  = "Block"
      },
      {
        type    = "Microsoft_BotManagerRuleSet"
        version = "1.0"
        action  = "Block"
      }
    ]
  }

  rule_sets = {
    "SecurityHeaders" = {
      rules = {
        "AddHsts" = {
          order = 1
          actions = {
            response_header_actions = [
              {
                header_action = "Overwrite"
                header_name   = "Strict-Transport-Security"
                value         = "max-age=31536000; includeSubDomains"
              }
            ]
          }
        }
        "AddCsp" = {
          order = 2
          actions = {
            response_header_actions = [
              {
                header_action = "Overwrite"
                header_name   = "X-Content-Type-Options"
                value         = "nosniff"
              }
            ]
          }
        }
      }
    }
    "UrlRewrites" = {
      rules = {
        "RewriteApiPath" = {
          order = 1
          conditions = {
            url_file_extension = null
            request_header     = null
          }
          actions = {
            url_rewrite = {
              source_pattern          = "/api/v1"
              destination             = "/api/v2"
              preserve_unmatched_path = true
            }
          }
        }
      }
    }
  }

  routes = {
    "web-route" = {
      endpoint_name       = "web"
      origin_group_name   = "web-origins"
      origin_names        = ["web-primary", "web-secondary"]
      patterns_to_match   = ["/*"]
      custom_domain_keys  = ["www"]
      rule_set_keys       = ["SecurityHeaders"]
      compression_enabled = true
      content_types_to_compress = [
        "text/html",
        "text/css",
        "application/javascript"
      ]
    }
    "api-route" = {
      endpoint_name       = "api"
      origin_group_name   = "api-origins"
      origin_names        = ["api-app"]
      patterns_to_match   = ["/api/*"]
      forwarding_protocol = "HttpsOnly"
      custom_domain_keys  = ["api"]
      rule_set_keys       = ["SecurityHeaders", "UrlRewrites"]
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

output "custom_domain_ids" {
  value = module.front_door.custom_domain_ids
}

output "custom_domain_validation_tokens" {
  value = module.front_door.custom_domain_validation_tokens
}

output "firewall_policy_id" {
  value = module.front_door.firewall_policy_id
}

output "rule_set_ids" {
  value = module.front_door.rule_set_ids
}
