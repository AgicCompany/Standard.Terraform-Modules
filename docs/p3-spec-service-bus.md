# Module: service-bus

**Priority:** P3
**Status:** Complete
**Target Version:** v1.0.0

## What It Creates

- `azurerm_servicebus_namespace` — Service Bus namespace
- `azurerm_servicebus_queue` — Queues (for_each)
- `azurerm_servicebus_topic` — Topics (for_each)
- `azurerm_servicebus_subscription` — Subscriptions (for_each via flattened local)
- `azurerm_private_endpoint` — Private endpoint (when `enable_private_endpoint = true`)

## v1.0.0 Scope

An Azure Service Bus namespace with queues, topics, subscriptions, and optional private endpoint.

### In Scope

- Namespace creation with configurable SKU (Basic, Standard, Premium)
- Queue management with configurable properties
- Topic and subscription management (Standard/Premium)
- Secure defaults (local auth disabled, public access disabled, TLS 1.2)
- Private endpoint for `namespace` subresource

### Out of Scope (Deferred)

- Authorization rules (namespace/queue/topic level)
- Subscription filter rules and correlation filters
- Dead letter queue management
- Network rule sets (IP/VNet rules)
- Customer-managed key encryption
- Diagnostic settings (use the standalone `diagnostic-settings` module)

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_private_endpoint` | `true` | Create a private endpoint for this namespace |
| `enable_public_access` | `false` | Allow public network access |
| `enable_local_auth` | `false` | Enable local authentication (SAS keys) |

## Private Endpoint Support

| Property | Value |
|----------|-------|
| Subresource name | `namespace` |
| Private DNS zone | `privatelink.servicebus.windows.net` |

### Variables (Private Endpoint)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `subnet_id` | string | Conditional | — | Subnet ID for private endpoint. Required when `enable_private_endpoint = true`. |
| `private_dns_zone_id` | string | Conditional | — | Private DNS zone ID. Required when `enable_private_endpoint = true`. |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sku` | string | No | `"Standard"` | SKU tier: `Basic`, `Standard`, or `Premium` |
| `capacity` | number | No | `0` | Messaging units for Premium (1, 2, 4, 8, 16). Must be 0 for Basic/Standard. |
| `minimum_tls_version` | string | No | `"1.2"` | Minimum TLS version |
| `queues` | map(object) | No | `{}` | Map of queues to create |
| `topics` | map(object) | No | `{}` | Map of topics with nested subscriptions |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `endpoint` | Service Bus namespace endpoint |
| `queue_ids` | Map of queue names to resource IDs |
| `topic_ids` | Map of topic names to resource IDs |
| `subscription_ids` | Map of subscription keys to resource IDs |
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address of the endpoint (when enabled) |
| `public_servicebus_id` | Namespace ID (public output) |
| `public_servicebus_name` | Namespace name (public output) |
| `public_servicebus_endpoint` | Namespace endpoint (public output) |

## Notes

- **SKU defaults to Standard:** Standard is cost-effective and supports topics, subscriptions, and most features. Premium is required for private endpoints and messaging units. Basic only supports queues (no topics).
- **Local auth disabled by default:** SAS key authentication is disabled. Modern workloads should use managed identity with RBAC roles.
- **Topics require Standard or Premium:** Basic SKU only supports queues.
- **Subscription flattening:** The `locals.tf` flattens nested `topics[*].subscriptions` into a flat map with `"topic_key/subscription_key"` keys for `for_each`.
