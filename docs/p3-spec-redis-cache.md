# Module: redis-cache

**Priority:** P3
**Status:** Complete
**Target Version:** v1.0.0

## What It Creates

- `azurerm_redis_cache` — Redis Cache instance
- `azurerm_redis_firewall_rule` — Firewall rules (for_each)
- `azurerm_private_endpoint` — Private endpoint (when `enable_private_endpoint = true`)

## v1.0.0 Scope

An Azure Redis Cache with secure defaults, firewall rules, and optional private endpoint.

### In Scope

- Redis Cache creation with configurable SKU (Basic, Standard, Premium)
- Redis configuration with customizable memory policies
- Firewall rules for IP-based access control
- Patch schedule support (Premium)
- Availability zone support (Premium)
- Private endpoint for `redisCache` subresource

### Out of Scope (Deferred)

- Redis clustering (Premium)
- Linked servers for geo-replication
- Customer-managed key encryption
- Redis modules
- Diagnostic settings (use the standalone `diagnostic-settings` module)

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_private_endpoint` | `true` | Create a private endpoint for this cache |
| `enable_public_access` | `false` | Allow public network access |
| `enable_non_ssl_port` | `false` | Enable the non-SSL port (6379) |

## Private Endpoint Support

| Property | Value |
|----------|-------|
| Subresource name | `redisCache` |
| Private DNS zone | `privatelink.redis.cache.windows.net` |

### Variables (Private Endpoint)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `subnet_id` | string | Conditional | — | Subnet ID for private endpoint. Required when `enable_private_endpoint = true`. |
| `private_dns_zone_id` | string | Conditional | — | Private DNS zone ID. Required when `enable_private_endpoint = true`. |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sku_name` | string | No | `"Basic"` | SKU tier: `Basic`, `Standard`, or `Premium` |
| `family` | string | No | `"C"` | SKU family: `C` (Basic/Standard) or `P` (Premium) |
| `capacity` | number | No | `0` | Cache size: 0-6 for C family, 1-5 for P family |
| `minimum_tls_version` | string | No | `"1.2"` | Minimum TLS version |
| `redis_configuration` | object | No | `{}` | Redis configuration (maxmemory_policy, etc.) |
| `patch_schedule` | object | No | `null` | Patch schedule (Premium only) |
| `firewall_rules` | map(object) | No | `{}` | Map of firewall rules |
| `zones` | list(string) | No | `[]` | Availability zones (Premium only) |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `hostname` | Redis Cache hostname |
| `ssl_port` | Redis Cache SSL port |
| `port` | Redis Cache non-SSL port |
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address of the endpoint (when enabled) |
| `public_redis_id` | Cache ID (public output) |
| `public_redis_name` | Cache name (public output) |
| `public_redis_hostname` | Cache hostname (public output) |

## Notes

- **SKU defaults to Basic:** Basic C0 is the most cost-effective option for development.
- **Provisioning time:** Redis Cache creation takes 15-25 minutes.
- **Access keys not exposed:** For security, primary and secondary access keys are not output.
- **Family mapping:** Use `C` family for Basic/Standard SKUs and `P` family for Premium.
- **Non-SSL port:** Port 6379 is disabled by default. Use port 6380 (SSL) for all new workloads.
