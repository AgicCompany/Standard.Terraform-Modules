# redis-cache

**Complexity:** Medium

Creates an Azure Redis Cache with secure defaults and optional private endpoint.

## Usage

```hcl
module "redis_cache" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//redis-cache?ref=redis-cache/v1.1.0"

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
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_redis_cache.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |
| [azurerm_redis_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Cache size: 0-6 for C family, 1-5 for P family | `number` | `0` | no |
| <a name="input_enable_non_ssl_port"></a> [enable\_non\_ssl\_port](#input\_enable\_non\_ssl\_port) | Enable the non-SSL port (6379). Not recommended. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this cache | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access | `bool` | `false` | no |
| <a name="input_family"></a> [family](#input\_family) | SKU family: C (Basic/Standard) or P (Premium) | `string` | `"C"` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Map of firewall rules. Key is the rule name. | <pre>map(object({<br/>    start_ip = string<br/>    end_ip   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Redis Cache name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_patch_schedule"></a> [patch\_schedule](#input\_patch\_schedule) | Patch schedule for Redis updates. Premium SKU only. | <pre>object({<br/>    day_of_week    = string<br/>    start_hour_utc = optional(number, 0)<br/>  })</pre> | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.redis.cache.windows.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_redis_configuration"></a> [redis\_configuration](#input\_redis\_configuration) | Redis configuration block. Premium-only fields (AOF, RDB) are ignored for lower SKUs. (sensitive) | <pre>object({<br/>    maxmemory_policy                = optional(string, "volatile-lru")<br/>    maxmemory_reserved              = optional(number)<br/>    maxfragmentationmemory_reserved = optional(number)<br/>    notify_keyspace_events          = optional(string)<br/>    aof_backup_enabled              = optional(bool)<br/>    rdb_backup_enabled              = optional(bool)<br/>    rdb_backup_frequency            = optional(number)<br/>    rdb_backup_max_snapshot_count   = optional(number)<br/>    rdb_storage_connection_string   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | Redis version: 6 | `string` | `"6"` | no |
| <a name="input_replicas_per_master"></a> [replicas\_per\_master](#input\_replicas\_per\_master) | Number of replicas per master. Premium SKU only. | `number` | `null` | no |
| <a name="input_replicas_per_primary"></a> [replicas\_per\_primary](#input\_replicas\_per\_primary) | Number of replicas per primary. Premium SKU only. | `number` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU tier: Basic, Standard, or Premium | `string` | `"Basic"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zones. Premium SKU only. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Redis Cache hostname |
| <a name="output_id"></a> [id](#output\_id) | Redis Cache resource ID |
| <a name="output_name"></a> [name](#output\_name) | Redis Cache name |
| <a name="output_port"></a> [port](#output\_port) | Redis Cache non-SSL port |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_redis_hostname"></a> [public\_redis\_hostname](#output\_public\_redis\_hostname) | Redis Cache hostname (for cross-project consumption) |
| <a name="output_public_redis_id"></a> [public\_redis\_id](#output\_public\_redis\_id) | Redis Cache resource ID (for cross-project consumption) |
| <a name="output_public_redis_name"></a> [public\_redis\_name](#output\_public\_redis\_name) | Redis Cache name (for cross-project consumption) |
| <a name="output_ssl_port"></a> [ssl\_port](#output\_ssl\_port) | Redis Cache SSL port |
<!-- END_TF_DOCS -->

## Notes

- **SKU defaults to Basic:** Basic C0 is the most cost-effective option for development. Standard adds replication, Premium adds clustering, persistence, and VNet injection. Private endpoints require Standard or Premium SKU.
- **Provisioning time:** Redis Cache creation takes 15-25 minutes. Plan accordingly.
- **Access keys not exposed:** For security, primary and secondary access keys are not output. Use managed identity or retrieve keys via Azure CLI/Portal when needed.
- **Family mapping:** Use `C` family for Basic/Standard SKUs and `P` family for Premium. Mismatched family/SKU combinations will fail.
- **Non-SSL port:** Port 6379 is disabled by default. Only enable for legacy clients that don't support TLS. Use port 6380 (SSL) for all new workloads.
- **Validated fields:** `maxmemory_policy` accepts: `volatile-lru`, `allkeys-lru`, `volatile-lfu`, `allkeys-lfu`, `volatile-random`, `allkeys-random`, `volatile-ttl`, `noeviction`. `patch_schedule.day_of_week` accepts day names (Monday-Sunday), `Everyday`, or `Weekend`.
- **AzureRM 4.x:** Uses `non_ssl_port_enabled` (not `enable_non_ssl_port`). The variable name uses `enable_` for framework consistency.
