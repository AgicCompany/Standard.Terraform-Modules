# Module: container-registry

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_container_registry` — Azure Container Registry
- `azurerm_private_endpoint` — Private endpoint (when `enable_private_endpoint = true`)
- `azurerm_private_endpoint_dns_zone_group` — DNS zone group (when `enable_private_endpoint = true`)

## v1.0.0 Scope

An Azure Container Registry with secure defaults and private endpoint support. Provides image hosting for container apps and AKS workloads.

### In Scope

- Container registry creation with configurable SKU
- Secure defaults (admin account disabled, public access disabled, content trust optional)
- Private endpoint for `registry` subresource
- Geo-replication support (Premium SKU only)
- Network rules (Premium SKU only)
- System-assigned managed identity (always enabled for ACR)

### Out of Scope (Deferred)

- Encryption with customer-managed key (CMK)
- Scope maps and tokens
- Webhooks
- Connected registries
- Cache rules
- Retention policies for untagged manifests
- Diagnostic settings (use the standalone `diagnostic-settings` module)

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_private_endpoint` | `false` | Create a private endpoint for this registry. Requires `sku = "Premium"`. |
| `enable_public_access` | `false` | Allow public network access |
| `enable_admin` | `false` | Enable admin account. Not recommended — use managed identity or service principals instead. |
| `enable_content_trust` | `false` | Enable content trust (image signing). Premium SKU only. |
| `enable_geo_replication` | `false` | Enable geo-replication. Premium SKU only. |

## Private Endpoint Support

| Property | Value |
|----------|-------|
| Subresource name | `registry` |
| Private DNS zone | `privatelink.azurecr.io` |

### Variables (Private Endpoint)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `subnet_id` | string | Conditional | — | Subnet ID for private endpoint. Required when `enable_private_endpoint = true`. |
| `private_dns_zone_id` | string | Conditional | — | Private DNS zone ID. Required when `enable_private_endpoint = true`. |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sku` | string | No | `"Standard"` | SKU tier: `Basic`, `Standard`, or `Premium`. Private endpoints require Premium — see validation. |
| `georeplications` | map(object) | No | `{}` | Geo-replication locations (see below). Premium SKU only. |

### Georeplications Variable Structure

```hcl
variable "georeplications" {
  type = map(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default     = {}
  description = "Geo-replication locations. Key is used as identifier. Premium SKU only."
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `login_server` | Login server URL (e.g., `myregistry.azurecr.io`) |
| `principal_id` | System-assigned managed identity principal ID |
| `tenant_id` | System-assigned managed identity tenant ID |
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address of the endpoint (when enabled) |
| `public_acr_id` | Registry ID (public output) |
| `public_acr_name` | Registry name (public output) |
| `public_acr_login_server` | Login server URL (public output) |

## Deferred

- **Customer-managed key encryption** — Requires Premium SKU and a Key Vault key. Add when compliance requires it.
- **Scope maps and tokens** — Fine-grained access control for repositories. Useful for CI/CD pipelines pulling specific repositories.
- **Retention policy** — Automatic cleanup of untagged manifests. Useful for cost management, add in v1.1.0.
- **Webhooks** — Event-driven notifications. Consumers can create `azurerm_container_registry_webhook` directly.
- **Network rules** — IP-based allow lists and virtual network rules. Premium SKU only. Consider for v1.1.0.

## Notes

- **SKU defaults to Standard:** The module defaults to `Standard` SKU for cost efficiency. However, private endpoints, geo-replication, and content trust require `Premium`. The module validates that `sku = "Premium"` when `enable_private_endpoint = true`, `enable_geo_replication = true`, or `enable_content_trust = true` — a clear validation error is raised if the SKU doesn't support the requested features. This keeps the default affordable while preventing silent deployment failures.
- **Naming constraint:** ACR names must be globally unique, 5-50 characters, alphanumeric only (no hyphens). Example: `crpaymentsdevweu001`. CAF prefix is `cr`.
- **Admin account:** Disabled by default. The admin account provides a username/password for `docker login`. This is a legacy pattern — modern workloads should use managed identity (`AcrPull` role) or service principals. The `enable_admin` flag exists for edge cases but is not recommended.
- **Managed identity for AKS/Container Apps:** To pull images from ACR, AKS and Container Apps should use managed identity with the `AcrPull` role assigned at the registry scope. This role assignment is the consumer's responsibility, not the module's.
- **Geo-replication:** Only available on Premium SKU. Provides image locality for multi-region deployments. Each replication location incurs additional costs.
- **Content trust:** Enables Docker Content Trust (image signing) for the registry. Premium SKU only. Requires additional client-side configuration (`DOCKER_CONTENT_TRUST=1`).
- **Private endpoint + public access:** When `enable_private_endpoint = true` and `enable_public_access = false`, the registry is only accessible from the VNet. CI/CD pipelines must either run within the VNet or use a self-hosted agent.
