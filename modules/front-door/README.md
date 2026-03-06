# front-door

**Complexity:** High

Creates an Azure Front Door profile with endpoints, origin groups, origins, and routes.

## Usage

```hcl
module "front_door" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//front-door?ref=front-door/v1.0.0"

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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_origin.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | Map of Front Door endpoints. Key is used as the endpoint name. | <pre>map(object({<br/>    enabled = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Front Door profile name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_origin_groups"></a> [origin\_groups](#input\_origin\_groups) | Map of origin groups with health probe and load balancing settings. | <pre>map(object({<br/>    session_affinity_enabled                                  = optional(bool, false)<br/>    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)<br/>    health_probe = optional(object({<br/>      interval_in_seconds = optional(number, 100)<br/>      path                = optional(string, "/")<br/>      protocol            = optional(string, "Https")<br/>      request_type        = optional(string, "HEAD")<br/>    }))<br/>    load_balancing = optional(object({<br/>      additional_latency_in_milliseconds = optional(number, 50)<br/>      sample_size                        = optional(number, 4)<br/>      successful_samples_required        = optional(number, 3)<br/>    }), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_origins"></a> [origins](#input\_origins) | Map of origins. Each origin references an origin\_group by key name. | <pre>map(object({<br/>    origin_group_name              = string<br/>    host_name                      = string<br/>    origin_host_header             = optional(string)<br/>    http_port                      = optional(number, 80)<br/>    https_port                     = optional(number, 443)<br/>    priority                       = optional(number, 1)<br/>    weight                         = optional(number, 1000)<br/>    certificate_name_check_enabled = optional(bool, true)<br/>    enabled                        = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_response_timeout_seconds"></a> [response\_timeout\_seconds](#input\_response\_timeout\_seconds) | Response timeout in seconds (16-240) | `number` | `60` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of routes. Each route references an endpoint and origin\_group by key name. | <pre>map(object({<br/>    endpoint_name          = string<br/>    origin_group_name      = string<br/>    origin_names           = optional(list(string))<br/>    patterns_to_match      = optional(list(string), ["/*"])<br/>    supported_protocols    = optional(list(string), ["Http", "Https"])<br/>    forwarding_protocol    = optional(string, "HttpsOnly")<br/>    https_redirect_enabled = optional(bool, true)<br/>    link_to_default_domain = optional(bool, true)<br/>    enabled                = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU: Standard\_AzureFrontDoor or Premium\_AzureFrontDoor | `string` | `"Standard_AzureFrontDoor"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_host_names"></a> [endpoint\_host\_names](#output\_endpoint\_host\_names) | Map of endpoint names to their host names |
| <a name="output_endpoint_ids"></a> [endpoint\_ids](#output\_endpoint\_ids) | Map of endpoint names to their resource IDs |
| <a name="output_id"></a> [id](#output\_id) | Front Door profile resource ID |
| <a name="output_name"></a> [name](#output\_name) | Front Door profile name |
| <a name="output_origin_group_ids"></a> [origin\_group\_ids](#output\_origin\_group\_ids) | Map of origin group names to their resource IDs |
| <a name="output_origin_ids"></a> [origin\_ids](#output\_origin\_ids) | Map of origin names to their resource IDs |
| <a name="output_public_frontdoor_endpoint_host_names"></a> [public\_frontdoor\_endpoint\_host\_names](#output\_public\_frontdoor\_endpoint\_host\_names) | Map of endpoint host names (for cross-project consumption) |
| <a name="output_public_frontdoor_id"></a> [public\_frontdoor\_id](#output\_public\_frontdoor\_id) | Front Door profile resource ID (for cross-project consumption) |
| <a name="output_public_frontdoor_name"></a> [public\_frontdoor\_name](#output\_public\_frontdoor\_name) | Front Door profile name (for cross-project consumption) |
| <a name="output_resource_guid"></a> [resource\_guid](#output\_resource\_guid) | Front Door profile resource GUID |
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | Map of route names to their resource IDs |
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
