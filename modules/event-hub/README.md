# event-hub

**Complexity:** Medium

Creates an Azure Event Hub namespace with event hubs, consumer groups, authorization rules, and optional private endpoint. Event Hubs is a fully managed real-time data ingestion and streaming platform.

## Usage

```hcl
module "event_hub" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//event-hub?ref=event-hub/v1.1.0"

  resource_group_name = "rg-evh-dev-weu-001"
  location            = "westeurope"
  name                = "evh-telemetry-dev-weu-001"

  event_hubs = {
    events = {
      partition_count   = 4
      message_retention = 7
      consumer_groups = {
        analytics = { user_metadata = "Analytics processing" }
      }
    }
  }

  # Private endpoint (required inputs when enable_private_endpoint = true)
  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.servicebus.windows.net"]

  tags = local.common_tags
}
```

## Features

- Event Hub namespace with configurable SKU (Basic, Standard, Premium)
- Multiple event hubs via `event_hubs` map
- Consumer groups per event hub
- Namespace-level authorization rules
- Private endpoint with DNS integration
- Auto-inflate for automatic throughput scaling
- Configurable TLS version

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Local authentication | Disabled | `enable_local_auth` |
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
| `public_namespace_id` | Event Hub namespace resource ID |
| `public_namespace_name` | Event Hub namespace name |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | Map of namespace-level authorization rules | <pre>map(object({<br/>    listen = optional(bool, false)<br/>    send   = optional(bool, false)<br/>    manage = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_auto_inflate_enabled"></a> [auto\_inflate\_enabled](#input\_auto\_inflate\_enabled) | Enable auto-inflate for throughput units (Standard/Premium only) | `bool` | `false` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Throughput units (Basic/Standard: 1-40, Premium: 1-16) | `number` | `1` | no |
| <a name="input_enable_local_auth"></a> [enable\_local\_auth](#input\_enable\_local\_auth) | Enable local (SAS key) authentication. Secure default: disabled. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this Event Hub namespace | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access | `bool` | `false` | no |
| <a name="input_event_hubs"></a> [event\_hubs](#input\_event\_hubs) | Map of Event Hubs to create within the namespace | <pre>map(object({<br/>    partition_count   = optional(number, 2)<br/>    message_retention = optional(number, 1)<br/>    consumer_groups = optional(map(object({<br/>      user_metadata = optional(string)<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_maximum_throughput_units"></a> [maximum\_throughput\_units](#input\_maximum\_throughput\_units) | Maximum throughput units when auto-inflate is enabled (1-40) | `number` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Event Hub namespace name | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.servicebus.windows.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | Event Hub namespace SKU | `string` | `"Standard"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authorization_rule_ids"></a> [authorization\_rule\_ids](#output\_authorization\_rule\_ids) | Map of authorization rule names to their resource IDs |
| <a name="output_consumer_group_ids"></a> [consumer\_group\_ids](#output\_consumer\_group\_ids) | Map of consumer group keys to their resource IDs |
| <a name="output_eventhub_ids"></a> [eventhub\_ids](#output\_eventhub\_ids) | Map of Event Hub names to their resource IDs |
| <a name="output_id"></a> [id](#output\_id) | Event Hub namespace resource ID |
| <a name="output_name"></a> [name](#output\_name) | Event Hub namespace name |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_namespace_id"></a> [public\_namespace\_id](#output\_public\_namespace\_id) | Event Hub namespace resource ID (for cross-project consumption) |
| <a name="output_public_namespace_name"></a> [public\_namespace\_name](#output\_public\_namespace\_name) | Event Hub namespace name (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **Basic SKU limitations:** The Basic SKU does not support consumer groups beyond the built-in `$Default` consumer group. Use Standard or Premium SKU if you need custom consumer groups.
- **Partition count is immutable:** The partition count of an event hub cannot be changed after creation. Plan accordingly.
- **Message retention limits:** Basic SKU supports 1 day retention, Standard supports up to 7 days, and Premium supports up to 90 days.
- **Auto-inflate:** Only available for Standard and Premium SKUs. When enabled, set `maximum_throughput_units` to control the upper limit.
- **Local authentication:** Disabled by default for security. Enable `enable_local_auth` if you need SAS key-based access. Prefer Azure AD (RBAC) authentication when possible.
- **Naming convention:** CAF prefix: `evh`. Example: `evh-telemetry-dev-weu-001`.
