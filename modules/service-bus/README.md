# service-bus

**Complexity:** Medium

Creates an Azure Service Bus namespace with queues, topics, subscriptions, and optional private endpoint.

## Usage

```hcl
module "service_bus" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/service-bus?ref=service-bus/v2.0.0"

  resource_group_name = "rg-messaging-dev-weu-001"
  location            = "westeurope"
  name                = "sb-messaging-dev-weu-001"

  queues = {
    "orders" = {}
  }

  # Private endpoint (required inputs when enable_private_endpoint = true)
  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.servicebus.windows.net"]

  tags = local.common_tags
}
```

## Features

- Configurable SKU (Basic, Standard, Premium)
- Queue management with configurable properties
- Topic and subscription management (Standard/Premium)
- Private endpoint with DNS integration

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Local auth (SAS) | Disabled | `enable_local_auth` |
| Public access | Disabled | `enable_public_access` |
| Private endpoint | Enabled | `enable_private_endpoint` |
| Minimum TLS | 1.2 | `minimum_tls_version` |

## Private Endpoint

When `enable_private_endpoint = true` (default), the following inputs are required:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoint |
| `private_dns_zone_id` | Private DNS zone ID for `privatelink.servicebus.windows.net` |

The module creates the private endpoint and configures DNS zone group registration.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_servicebus_id` | Service Bus namespace resource ID |
| `public_servicebus_name` | Service Bus namespace name |
| `public_servicebus_endpoint` | Service Bus namespace endpoint |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
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
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_servicebus_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) | resource |
| [azurerm_servicebus_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Messaging units for Premium SKU (1, 2, 4, 8, or 16). Must be 0 for Basic/Standard. | `number` | `0` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled\_log\_categories = null -> all categories the resource supports. enabled\_metrics = null -> all metrics the resource supports. At least one of log\_analytics\_workspace\_id, storage\_account\_id, or eventhub\_authorization\_rule\_id is required when the object is non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_enable_local_auth"></a> [enable\_local\_auth](#input\_enable\_local\_auth) | Enable local authentication (SAS keys). Disabled by default — use managed identity. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this namespace | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version. Only "1.2" is supported; TLS 1.0/1.1 retired by Azure. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Service Bus namespace name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.servicebus.windows.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint resource name. Defaults to pep-{name}. | `string` | `null` | no |
| <a name="input_private_endpoint_nic_name"></a> [private\_endpoint\_nic\_name](#input\_private\_endpoint\_nic\_name) | Override the PE network interface name. Defaults to pep-{name}-nic. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Override the private service connection name. Defaults to psc-{name}. | `string` | `null` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | Map of queues to create. Key is the queue name. | <pre>map(object({<br/>    max_size_in_megabytes                   = optional(number, 1024)<br/>    default_message_ttl                     = optional(string)<br/>    lock_duration                           = optional(string)<br/>    max_delivery_count                      = optional(number, 10)<br/>    dead_lettering_on_message_expiration    = optional(bool, false)<br/>    enable_partitioning                     = optional(bool, false)<br/>    enable_batched_operations               = optional(bool, true)<br/>    requires_session                        = optional(bool, false)<br/>    requires_duplicate_detection            = optional(bool, false)<br/>    duplicate_detection_history_time_window = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU tier: Basic, Standard, or Premium | `string` | `"Standard"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Map of topics to create. Key is the topic name. Topics require Standard or Premium SKU. | <pre>map(object({<br/>    max_size_in_megabytes                   = optional(number, 1024)<br/>    default_message_ttl                     = optional(string)<br/>    enable_partitioning                     = optional(bool, false)<br/>    enable_batched_operations               = optional(bool, true)<br/>    requires_duplicate_detection            = optional(bool, false)<br/>    duplicate_detection_history_time_window = optional(string)<br/>    subscriptions = optional(map(object({<br/>      max_delivery_count                   = optional(number, 10)<br/>      lock_duration                        = optional(string)<br/>      default_message_ttl                  = optional(string)<br/>      dead_lettering_on_message_expiration = optional(bool, false)<br/>      enable_batched_operations            = optional(bool, true)<br/>      requires_session                     = optional(bool, false)<br/>    })), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Service Bus namespace endpoint |
| <a name="output_id"></a> [id](#output\_id) | Service Bus namespace resource ID |
| <a name="output_name"></a> [name](#output\_name) | Service Bus namespace name |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_servicebus_endpoint"></a> [public\_servicebus\_endpoint](#output\_public\_servicebus\_endpoint) | Service Bus namespace endpoint (for cross-project consumption) |
| <a name="output_public_servicebus_id"></a> [public\_servicebus\_id](#output\_public\_servicebus\_id) | Service Bus namespace resource ID (for cross-project consumption) |
| <a name="output_public_servicebus_name"></a> [public\_servicebus\_name](#output\_public\_servicebus\_name) | Service Bus namespace name (for cross-project consumption) |
| <a name="output_queue_ids"></a> [queue\_ids](#output\_queue\_ids) | Map of queue names to their resource IDs |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | Map of subscription keys (topic/subscription) to their resource IDs |
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | Map of topic names to their resource IDs |
<!-- END_TF_DOCS -->

## Notes

- **SKU defaults to Standard:** Standard is cost-effective and supports topics, subscriptions, and most features. Premium is required for private endpoints and messaging units. Basic only supports queues (no topics).
- **Local auth disabled by default:** SAS key authentication is disabled. Modern workloads should use managed identity with RBAC roles (`Azure Service Bus Data Sender`, `Azure Service Bus Data Receiver`). Set `enable_local_auth = true` for legacy scenarios.
- **Topics require Standard or Premium:** Basic SKU only supports queues. If you define topics with Basic SKU, the deployment will fail.
- **Premium messaging partitions:** For Premium SKU, the module sets `premium_messaging_partitions` based on capacity. Each partition provides dedicated throughput.
