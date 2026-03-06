# application-gateway

**Complexity:** High

Creates an Azure Application Gateway (v2) with a Standard SKU public IP for L7 load balancing, URL-based routing, SSL termination, health probes, and optional WAF support.

## Usage

```hcl
module "application_gateway" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/application-gateway?ref=application-gateway/v1.1.0"

  resource_group_name = "rg-appgw-dev-weu-001"
  location            = "westeurope"
  name                = "agw-payments-dev-weu-001"
  subnet_id           = module.virtual_network.subnet_ids["snet-appgw"]

  backend_address_pools = {
    web-servers = {
      fqdns = ["app.example.com"]
    }
  }

  backend_http_settings = {
    web-http = {
      port     = 80
      protocol = "Http"
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
      backend_address_pool_name  = "web-servers"
      backend_http_settings_name = "web-http"
    }
  }

  tags = local.common_tags
}
```

## Features

- Application Gateway v2 with autoscaling (Standard_v2 or WAF_v2)
- Public IP (Standard SKU, Static allocation)
- Backend address pools with FQDN or IP address targets
- Backend HTTP settings with configurable affinity, timeouts, and host headers
- HTTP/HTTPS listeners with optional host-based routing
- Request routing rules (Basic and PathBasedRouting)
- Health probes with custom paths, intervals, and match conditions
- SSL certificates (PFX upload or Key Vault reference)
- Redirect configurations (permanent, temporary, etc.)
- URL path maps for path-based routing
- Availability zone support
- HTTP/2 enabled by default
- External WAF policy attachment (firewall_policy_id)

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| HTTP/2 | Enabled | `enable_http2` |
| Public IP SKU | Standard | N/A (required for v2) |
| Public IP allocation | Static | N/A (required for v2) |

## Internal Cross-References

All sub-resources (backend pools, HTTP settings, listeners, rules, probes) are defined as map variables where the **map key** serves as the resource name. Internal cross-references between sub-resources use these map keys:

```hcl
# The routing rule references a listener and backend pool by their map keys
request_routing_rules = {
  web-rule = {
    http_listener_name         = "http-listener"    # key from http_listeners
    backend_address_pool_name  = "web-servers"       # key from backend_address_pools
    backend_http_settings_name = "web-http"           # key from backend_http_settings
  }
}
```

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_appgw_id` | Application Gateway resource ID |
| `public_appgw_public_ip` | Application Gateway public IP address |

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
| [azurerm_application_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscale"></a> [autoscale](#input\_autoscale) | Autoscale configuration (min 0-100, max 2-125) | <pre>object({<br/>    min_capacity = number<br/>    max_capacity = optional(number)<br/>  })</pre> | <pre>{<br/>  "max_capacity": 2,<br/>  "min_capacity": 1<br/>}</pre> | no |
| <a name="input_backend_address_pools"></a> [backend\_address\_pools](#input\_backend\_address\_pools) | Map of backend address pools. Key is used as the pool name. | <pre>map(object({<br/>    fqdns        = optional(list(string), [])<br/>    ip_addresses = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | Map of backend HTTP settings. Key is used as the setting name. | <pre>map(object({<br/>    port                                      = number<br/>    protocol                                  = string<br/>    cookie_based_affinity                     = optional(string, "Disabled")<br/>    request_timeout                           = optional(number, 30)<br/>    probe_name                                = optional(string, null)<br/>    host_name                                 = optional(string, null)<br/>    pick_host_name_from_backend_http_settings = optional(bool, false)<br/>    path                                      = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Enable HTTP/2 | `bool` | `true` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | WAF policy resource ID (for WAF\_v2 SKU) | `string` | `null` | no |
| <a name="input_frontend_ports"></a> [frontend\_ports](#input\_frontend\_ports) | Map of frontend ports. Key is used as the port name. | <pre>map(object({<br/>    port = number<br/>  }))</pre> | <pre>{<br/>  "http": {<br/>    "port": 80<br/>  },<br/>  "https": {<br/>    "port": 443<br/>  }<br/>}</pre> | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | Map of HTTP listeners. Key is used as the listener name. | <pre>map(object({<br/>    frontend_port_name   = string<br/>    protocol             = string<br/>    host_name            = optional(string, null)<br/>    host_names           = optional(list(string), null)<br/>    ssl_certificate_name = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Application Gateway name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_probes"></a> [probes](#input\_probes) | Map of health probes. Key is used as the probe name. | <pre>map(object({<br/>    protocol                                  = string<br/>    path                                      = string<br/>    host                                      = optional(string, null)<br/>    interval                                  = optional(number, 30)<br/>    timeout                                   = optional(number, 30)<br/>    unhealthy_threshold                       = optional(number, 3)<br/>    pick_host_name_from_backend_http_settings = optional(bool, false)<br/>    minimum_servers                           = optional(number, 0)<br/>    match_status_codes                        = optional(list(string), ["200-399"])<br/>  }))</pre> | `{}` | no |
| <a name="input_redirect_configurations"></a> [redirect\_configurations](#input\_redirect\_configurations) | Map of redirect configurations. Key is used as the configuration name. | <pre>map(object({<br/>    redirect_type        = string<br/>    target_listener_name = optional(string, null)<br/>    target_url           = optional(string, null)<br/>    include_path         = optional(bool, true)<br/>    include_query_string = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_request_routing_rules"></a> [request\_routing\_rules](#input\_request\_routing\_rules) | Map of request routing rules. Key is used as the rule name. | <pre>map(object({<br/>    rule_type                   = optional(string, "Basic")<br/>    priority                    = number<br/>    http_listener_name          = string<br/>    backend_address_pool_name   = optional(string, null)<br/>    backend_http_settings_name  = optional(string, null)<br/>    url_path_map_name           = optional(string, null)<br/>    redirect_configuration_name = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the Application Gateway | `string` | `"Standard_v2"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier for the Application Gateway | `string` | `"Standard_v2"` | no |
| <a name="input_ssl_certificates"></a> [ssl\_certificates](#input\_ssl\_certificates) | Map of SSL certificates. Key is used as the certificate name. Provide either data+password (PFX) or key\_vault\_secret\_id. | <pre>map(object({<br/>    data                = optional(string, null)<br/>    password            = optional(string, null)<br/>    key_vault_secret_id = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the Application Gateway (dedicated subnet, minimum /24 recommended) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_url_path_maps"></a> [url\_path\_maps](#input\_url\_path\_maps) | Map of URL path maps. Key is used as the path map name. | <pre>map(object({<br/>    default_backend_address_pool_name   = optional(string, null)<br/>    default_backend_http_settings_name  = optional(string, null)<br/>    default_redirect_configuration_name = optional(string, null)<br/>    path_rules = map(object({<br/>      paths                       = list(string)<br/>      backend_address_pool_name   = optional(string, null)<br/>      backend_http_settings_name  = optional(string, null)<br/>      redirect_configuration_name = optional(string, null)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zones | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address_pool_ids"></a> [backend\_address\_pool\_ids](#output\_backend\_address\_pool\_ids) | Map of backend address pool names to IDs |
| <a name="output_id"></a> [id](#output\_id) | Application Gateway resource ID |
| <a name="output_name"></a> [name](#output\_name) | Application Gateway name |
| <a name="output_public_appgw_id"></a> [public\_appgw\_id](#output\_public\_appgw\_id) | Application Gateway resource ID (for cross-project consumption) |
| <a name="output_public_appgw_public_ip"></a> [public\_appgw\_public\_ip](#output\_public\_appgw\_public\_ip) | Application Gateway public IP (for cross-project consumption) |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address of the Application Gateway |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | Public IP resource ID |
<!-- END_TF_DOCS -->

## Notes

- **Dedicated subnet required:** Application Gateway v2 requires a dedicated subnet with no other resources. Minimum /24 is recommended for production.
- **v2 SKUs only:** This module supports only `Standard_v2` and `WAF_v2` SKUs. Legacy v1 SKUs are not supported.
- **WAF policy is external:** The module does not create WAF policies. Consumers provide a `firewall_policy_id` if WAF is needed.
- **Internal cross-references use map keys:** Routing rules reference listeners, backend pools, and HTTP settings by their map key names, not resource IDs.
- **Validated fields:** `protocol` (`Http`/`Https`) on backend HTTP settings, listeners, and probes. `cookie_based_affinity` (`Enabled`/`Disabled`). `rule_type` (`Basic`/`PathBasedRouting`). `redirect_type` (`Permanent`/`Found`/`SeeOther`/`Temporary`). All case-sensitive.
- **Provisioning time:** Application Gateway creation takes 5-10 minutes. Plan accordingly.
- **No private endpoint:** Application Gateway uses a dedicated subnet and does not support private endpoints. It provides L7 load balancing to backend services.
- **Naming:** CAF prefix for Application Gateway is `agw`. Example: `agw-payments-dev-weu-001`.
