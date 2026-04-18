# managed-redis

Creates an Azure Managed Redis instance with secure defaults and optional private endpoint.

## Usage

```hcl
module "managed_redis" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/managed-redis?ref=managed-redis/v1.0.0"

  resource_group_name = "rg-caching-dev-weu-001"
  location            = "westeurope"
  name                = "amr-caching-dev-weu-001"
  sku_name            = "Balanced_B10"

  # Private endpoint (required inputs when enable_private_endpoint = true)
  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.redis.azure.net"]

  tags = local.common_tags
}
```

## Features

- Configurable SKU (Balanced, ComputeOptimized, MemoryOptimized)
- Database configuration (clustering policy, eviction policy, client protocol)
- Redis modules (RediSearch, RedisJSON, RedisBloom, RedisTimeSeries)
- Active-active geo-replication
- Data persistence (AOF or RDB)
- Managed identity and customer-managed key encryption
- Private endpoint with configurable naming
- Secure defaults (Encrypted protocol, Entra ID auth, private endpoint enabled, public access disabled)

## Secure Defaults

| Setting | Default | Override |
|---|---|---|
| Client protocol | Encrypted (TLS) | `client_protocol = "Plaintext"` |
| Access key auth | Disabled (Entra ID) | `access_keys_authentication_enabled = true` |
| Private endpoint | Enabled | `enable_private_endpoint = false` |
| Public access | Disabled | `enable_public_access = true` |
| High availability | Enabled | `high_availability_enabled = false` |

## Important Constraints

- **Clustering policy** cannot be changed after creation (forces replacement)
- **Redis modules** cannot be added or removed after creation (forces replacement)
- **RediSearch** requires `clustering_policy = "EnterpriseCluster"` and `eviction_policy = "NoEviction"`
- **Geo-replication** requires HA enabled, no persistence, and only RediSearch/RedisJSON modules
- **Persistence** is AOF or RDB, not both — and incompatible with geo-replication
- **Flash Optimized** SKUs are not supported (still in Preview)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.54.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.54.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_redis.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_keys_authentication_enabled"></a> [access\_keys\_authentication\_enabled](#input\_access\_keys\_authentication\_enabled) | Enable access key authentication. Disabled by default (Entra ID only). | `bool` | `false` | no |
| <a name="input_client_protocol"></a> [client\_protocol](#input\_client\_protocol) | Client protocol: Encrypted (TLS) or Plaintext | `string` | `"Encrypted"` | no |
| <a name="input_clustering_policy"></a> [clustering\_policy](#input\_clustering\_policy) | Clustering policy: OSSCluster, EnterpriseCluster, or NoCluster. Cannot be changed after creation (forces replacement). | `string` | `"OSSCluster"` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed key for encryption. Requires an identity block with UserAssigned. | <pre>object({<br/>    key_vault_key_id = string<br/>    identity_id      = string<br/>  })</pre> | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled\_log\_categories = null -> all categories the resource supports. enabled\_metrics = null -> all metrics the resource supports. At least one of log\_analytics\_workspace\_id, storage\_account\_id, or eventhub\_authorization\_rule\_id is required when the object is non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this instance | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access | `bool` | `false` | no |
| <a name="input_eviction_policy"></a> [eviction\_policy](#input\_eviction\_policy) | Eviction policy for the default database | `string` | `"VolatileLRU"` | no |
| <a name="input_geo_replication_group_name"></a> [geo\_replication\_group\_name](#input\_geo\_replication\_group\_name) | Active-active geo-replication group name. All instances sharing this name are linked. Forces replacement. | `string` | `null` | no |
| <a name="input_high_availability_enabled"></a> [high\_availability\_enabled](#input\_high\_availability\_enabled) | Enable high availability. Cannot be changed after creation (forces replacement). | `bool` | `true` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration. type must be "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned". | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_modules"></a> [modules](#input\_modules) | Redis modules to enable (RediSearch, RedisJSON, RedisBloom, RedisTimeSeries). Cannot be changed after creation (forces replacement). | <pre>list(object({<br/>    name = string<br/>    args = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Managed Redis instance name (full CAF-compliant name, provided by consumer). Globally unique. | `string` | n/a | yes |
| <a name="input_persistence_aof_frequency"></a> [persistence\_aof\_frequency](#input\_persistence\_aof\_frequency) | AOF persistence backup frequency. Only valid value is "1s". Mutually exclusive with RDB persistence and geo-replication. | `string` | `null` | no |
| <a name="input_persistence_rdb_frequency"></a> [persistence\_rdb\_frequency](#input\_persistence\_rdb\_frequency) | RDB persistence backup frequency: "1h", "6h", or "12h". Mutually exclusive with AOF persistence and geo-replication. | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.redis.azure.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint resource name. Defaults to pep-{name}. | `string` | `null` | no |
| <a name="input_private_endpoint_nic_name"></a> [private\_endpoint\_nic\_name](#input\_private\_endpoint\_nic\_name) | Override the PE network interface name. Defaults to pep-{name}-nic. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Override the private service connection name. Defaults to psc-{name}. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU tier and capacity (e.g. Balanced\_B10, ComputeOptimized\_X10, MemoryOptimized\_M20). See https://learn.microsoft.com/en-us/azure/redis/managed-redis-overview for valid sizes. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Managed Redis hostname |
| <a name="output_id"></a> [id](#output\_id) | Managed Redis resource ID |
| <a name="output_name"></a> [name](#output\_name) | Managed Redis instance name |
| <a name="output_port"></a> [port](#output\_port) | Managed Redis default database port |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
<!-- END_TF_DOCS -->
