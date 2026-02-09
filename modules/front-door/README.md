# front-door

**Complexity:** High

Creates an Azure Front Door profile with endpoints, origin groups, origins, and routes.

## Usage

```hcl
module "front_door" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//front-door?ref=front-door/v1.0.0"

  resource_group_name = "rg-cdn-dev-weu-001"
  name                = "afd-web-dev-001"

  endpoints = {
    "web" = {}
  }

  origin_groups = {
    "web-origins" = {
      health_probe = {
        path     = "/health"
        protocol = "Https"
      }
    }
  }

  origins = {
    "web-app" = {
      origin_group_name = "web-origins"
      host_name         = "app-web-dev-weu-001.azurewebsites.net"
    }
  }

  routes = {
    "web-route" = {
      endpoint_name     = "web"
      origin_group_name = "web-origins"
    }
  }

  tags = local.common_tags
}
```

## Features

- Configurable SKU (Standard, Premium)
- Endpoint management with for_each
- Origin group management with health probes and load balancing
- Origin management with weighted routing and priority
- Route management with pattern matching and protocol configuration
- Cross-reference between resources using map keys

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| HTTPS redirect | Enabled | `routes[].https_redirect_enabled` |
| Forwarding protocol | HttpsOnly | `routes[].forwarding_protocol` |
| Certificate name check | Enabled | `origins[].certificate_name_check_enabled` |
| Response timeout | 60s | `response_timeout_seconds` |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_frontdoor_id` | Front Door profile resource ID |
| `public_frontdoor_name` | Front Door profile name |
| `public_frontdoor_endpoint_host_names` | Map of endpoint host names |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **No location variable:** Front Door is a global resource. The profile is created in the resource group's region but serves traffic globally.
- **No private endpoint:** Front Door is a global edge service. Origin Private Link (connecting Front Door to private origins) is deferred to a future version.
- **Endpoint names must be globally unique:** Front Door endpoint names become part of the FQDN (`<name>.azurefd.net`). Choose unique names.
- **Tags on profile and endpoints only:** Origin groups, origins, and routes do not support tags in the AzureRM provider.
- **Cross-referencing:** Origins reference origin groups by key name. Routes reference endpoints and origin groups by key name. This enables declarative configuration without hardcoded IDs.
- **Origin host header:** Defaults to the origin hostname if not specified. Override when the backend requires a specific host header (e.g., App Service custom domains).
- **Load balancing is always included:** AzureRM 4.x requires the load_balancing block on origin groups. The module provides sensible defaults.
- **Most complex P3 module:** Due to the number of interconnected resources, carefully review the variable maps to ensure cross-references are correct.
