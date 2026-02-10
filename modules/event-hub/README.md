# event-hub

**Complexity:** Medium

Creates an Azure Event Hub namespace with event hubs, consumer groups, authorization rules, and optional private endpoint. Event Hubs is a fully managed real-time data ingestion and streaming platform.

## Usage

```hcl
module "event_hub" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//event-hub?ref=event-hub/v1.0.0"

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
<!-- END_TF_DOCS -->

## Notes

- **Basic SKU limitations:** The Basic SKU does not support consumer groups beyond the built-in `$Default` consumer group. Use Standard or Premium SKU if you need custom consumer groups.
- **Partition count is immutable:** The partition count of an event hub cannot be changed after creation. Plan accordingly.
- **Message retention limits:** Basic SKU supports 1 day retention, Standard supports up to 7 days, and Premium supports up to 90 days.
- **Auto-inflate:** Only available for Standard and Premium SKUs. When enabled, set `maximum_throughput_units` to control the upper limit.
- **Local authentication:** Disabled by default for security. Enable `enable_local_auth` if you need SAS key-based access. Prefer Azure AD (RBAC) authentication when possible.
- **Naming convention:** CAF prefix: `evh`. Example: `evh-telemetry-dev-weu-001`.
