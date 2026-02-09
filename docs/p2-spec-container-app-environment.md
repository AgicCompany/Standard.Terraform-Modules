# Module: container-app-environment

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_container_app_environment` — Azure Container Apps Environment (the shared hosting layer for container apps)

## v1.0.0 Scope

A Container Apps Environment that provides the shared infrastructure for running container apps. This is analogous to a service plan for App Service — it defines the hosting layer. Individual container apps are deployed into this environment via the `container-app` module.

### In Scope

- Container Apps Environment creation
- Log Analytics workspace integration (required by Azure)
- VNet integration for internal environments
- Internal load balancer option
- Workload profile configuration (Consumption and Dedicated)
- Zone redundancy support

### Out of Scope (Deferred)

- Dapr component configuration (use `azurerm_container_app_environment_dapr_component` directly)
- Custom domain and certificate management
- Storage mounts at the environment level
- Peer-to-peer encryption

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_internal_load_balancer` | `true` | Use internal load balancer (no public IP on the environment). Requires VNet integration. |
| `enable_zone_redundancy` | `false` | Enable zone redundant deployment |

## Private Endpoint Support

Not directly applicable. Container Apps Environments use VNet integration with an internal load balancer for private access, rather than Azure Private Link. The `enable_internal_load_balancer` flag controls this.

When `enable_internal_load_balancer = true`, the environment gets a private IP and apps are not publicly accessible unless explicitly configured with external ingress.

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `log_analytics_workspace_id` | string | Yes | — | Log Analytics workspace ID for environment logging |
| `infrastructure_subnet_id` | string | Conditional | — | Subnet ID for VNet integration. Required when `enable_internal_load_balancer = true`. |
| `workload_profiles` | map(object) | No | `{}` | Workload profiles for dedicated compute (see below) |

### Workload Profiles Variable Structure

```hcl
variable "workload_profiles" {
  type = map(object({
    workload_profile_type = string  # D4, D8, D16, D32, E4, E8, E16, E32
    minimum_count         = number
    maximum_count         = number
  }))
  default     = {}
  description = "Dedicated workload profiles. Key is used as profile name. Empty map = Consumption only."
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `default_domain` | Default domain of the environment (used by container apps for FQDN) |
| `static_ip_address` | Static IP address of the environment |
| `docker_bridge_cidr` | Docker bridge CIDR |
| `platform_reserved_cidr` | Platform reserved CIDR |
| `platform_reserved_dns_ip_address` | Platform reserved DNS IP |
| `public_container_app_environment_id` | Environment ID (public output for cross-project consumption) |
| `public_container_app_environment_default_domain` | Default domain (public output) |

## Deferred

- **Dapr components** — Dapr configuration is application-specific. Consumers create `azurerm_container_app_environment_dapr_component` resources directly at the project level.
- **Environment storage** — `azurerm_container_app_environment_storage` for mounting Azure Files shares. Add when demand exists.
- **Custom domain verification** — `azurerm_container_app_environment_custom_domain` for custom domains at the environment level.
- **Peer-to-peer TLS encryption** — `peer_to_peer_tls_enabled` setting. Evaluate for v1.1.0.
- **Mutual TLS** — `mutual_tls_enabled` setting. Security feature, consider enabling by default in a future version.

## Notes

- **Subnet requirements:** The subnet used for VNet integration must be dedicated to the Container Apps Environment (no other resources). It needs a minimum `/23` CIDR range (`/21` recommended for production). The subnet must be delegated to `Microsoft.App/environments`.
- **Internal vs external:** When `enable_internal_load_balancer = true`, the environment's default domain resolves to a private IP. Individual container apps can still expose external ingress if needed, but the environment itself is private. When `false`, the environment gets a public IP.
- **Log Analytics requirement:** Azure requires a Log Analytics workspace for Container Apps Environments. This is not optional — the `log_analytics_workspace_id` is always required.
- **Workload profiles:** An empty `workload_profiles` map means Consumption-only plan. Adding workload profiles enables dedicated compute with guaranteed resources. The `Consumption` profile is always available even when dedicated profiles exist.
- **Zone redundancy:** Requires a VNet-integrated environment. Cannot be changed after creation — this is a create-time setting.
- **Naming:** CAF prefix for Container Apps Environments is `cae`. Example: `cae-payments-dev-weu-001`.
- **One environment, many apps:** Similar to an App Service Plan, one environment hosts multiple container apps. The environment defines the networking and logging; the apps define the workloads.
- **Relationship to container-app module:** This module creates the environment. The `container-app` module creates individual apps within the environment. The environment `id` output is the link between them.
