# application-gateway

**Complexity:** High

Creates an Azure Application Gateway (v2) with a Standard SKU public IP for L7 load balancing, URL-based routing, SSL termination, health probes, and optional WAF support.

## Usage

```hcl
module "application_gateway" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//application-gateway?ref=application-gateway/v1.0.0"

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
<!-- END_TF_DOCS -->

## Notes

- **Dedicated subnet required:** Application Gateway v2 requires a dedicated subnet with no other resources. Minimum /24 is recommended for production.
- **v2 SKUs only:** This module supports only `Standard_v2` and `WAF_v2` SKUs. Legacy v1 SKUs are not supported.
- **WAF policy is external:** The module does not create WAF policies. Consumers provide a `firewall_policy_id` if WAF is needed.
- **Internal cross-references use map keys:** Routing rules reference listeners, backend pools, and HTTP settings by their map key names, not resource IDs.
- **Provisioning time:** Application Gateway creation takes 5-10 minutes. Plan accordingly.
- **No private endpoint:** Application Gateway uses a dedicated subnet and does not support private endpoints. It provides L7 load balancing to backend services.
- **Naming:** CAF prefix for Application Gateway is `agw`. Example: `agw-payments-dev-weu-001`.
