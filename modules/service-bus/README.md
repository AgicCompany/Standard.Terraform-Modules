# service-bus

**Complexity:** Medium

Creates an Azure Service Bus namespace with queues, topics, subscriptions, and optional private endpoint.

## Usage

```hcl
module "service_bus" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//service-bus?ref=service-bus/v1.0.0"

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
<!-- END_TF_DOCS -->

## Notes

- **SKU defaults to Standard:** Standard is cost-effective and supports topics, subscriptions, and most features. Premium is required for private endpoints and messaging units. Basic only supports queues (no topics).
- **Local auth disabled by default:** SAS key authentication is disabled. Modern workloads should use managed identity with RBAC roles (`Azure Service Bus Data Sender`, `Azure Service Bus Data Receiver`). Set `enable_local_auth = true` for legacy scenarios.
- **Topics require Standard or Premium:** Basic SKU only supports queues. If you define topics with Basic SKU, the deployment will fail.
- **Premium messaging partitions:** For Premium SKU, the module sets `premium_messaging_partitions` based on capacity. Each partition provides dedicated throughput.
