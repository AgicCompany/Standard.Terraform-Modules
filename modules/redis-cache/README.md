# redis-cache

**Complexity:** Medium

Creates an Azure Redis Cache with secure defaults and optional private endpoint.

## Usage

```hcl
module "redis_cache" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//redis-cache?ref=redis-cache/v1.0.0"

  resource_group_name = "rg-caching-dev-weu-001"
  location            = "westeurope"
  name                = "redis-caching-dev-weu-001"

  # Private endpoint (required inputs when enable_private_endpoint = true)
  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.redis.cache.windows.net"]

  tags = local.common_tags
}
```

## Features

- Configurable SKU (Basic, Standard, Premium)
- Redis configuration with customizable memory policies
- Firewall rules for IP-based access control
- Patch schedule support (Premium)
- Availability zone support (Premium)
- Private endpoint with DNS integration

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Minimum TLS | 1.2 | `minimum_tls_version` |
| Non-SSL port | Disabled | `enable_non_ssl_port` |
| Public access | Disabled | `enable_public_access` |
| Private endpoint | Enabled | `enable_private_endpoint` |

## Private Endpoint

When `enable_private_endpoint = true` (default), the following inputs are required:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoint |
| `private_dns_zone_id` | Private DNS zone ID for `privatelink.redis.cache.windows.net` |

The module creates the private endpoint and configures DNS zone group registration.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_redis_id` | Redis Cache resource ID |
| `public_redis_name` | Redis Cache name |
| `public_redis_hostname` | Redis Cache hostname |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **SKU defaults to Basic:** Basic C0 is the most cost-effective option for development. Standard adds replication, Premium adds clustering, persistence, and VNet injection. Private endpoints work with all SKUs.
- **Provisioning time:** Redis Cache creation takes 15-25 minutes. Plan accordingly.
- **Access keys not exposed:** For security, primary and secondary access keys are not output. Use managed identity or retrieve keys via Azure CLI/Portal when needed.
- **Family mapping:** Use `C` family for Basic/Standard SKUs and `P` family for Premium. Mismatched family/SKU combinations will fail.
- **Non-SSL port:** Port 6379 is disabled by default. Only enable for legacy clients that don't support TLS. Use port 6380 (SSL) for all new workloads.
- **AzureRM 4.x:** Uses `non_ssl_port_enabled` (not `enable_non_ssl_port`). The variable name uses `enable_` for framework consistency.
