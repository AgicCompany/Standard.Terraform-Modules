# Module: container-app

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_container_app` — Azure Container App

## v1.0.0 Scope

A Container App deployed into an existing Container Apps Environment. Supports single-container workloads with ingress configuration, secrets management, and scaling rules.

### In Scope

- Container app creation in an existing environment
- Single-container template with configurable image, CPU, memory
- Ingress configuration (HTTP, TCP) with external/internal toggle
- Environment variables (plain text and secret references)
- Secrets management (values passed by consumer)
- System-assigned and user-assigned managed identity
- Revision mode (Single or Multiple)
- Scale rules (min/max replicas, HTTP concurrent requests)
- Init containers
- Liveness, readiness, and startup probes

### Out of Scope (Deferred)

- Multi-container templates (sidecar patterns) — evaluate for v1.1.0
- Dapr configuration — consumers configure at the environment level
- Volume mounts (Azure Files, EmptyDir, Secret)
- Traffic splitting between revisions (requires `Multiple` revision mode + traffic weight config)
- Custom domains and certificates at the app level
- Custom scaling rules (KEDA-based: Azure Queue, Service Bus, etc.)
- Service-to-service communication via Dapr or service discovery

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_ingress` | `true` | Enable HTTP/TCP ingress for this container app |
| `enable_external_ingress` | `false` | Allow ingress from outside the Container Apps Environment. When `false`, only internal traffic is allowed. |
| `enable_system_assigned_identity` | `false` | Enable system-assigned managed identity |

## Private Endpoint Support

Not directly applicable. Container Apps inherit their network posture from the Container Apps Environment. If the environment uses an internal load balancer, the app is private. External ingress on the app controls whether traffic from outside the environment is accepted.

## Variables

Beyond the standard interface (`resource_group_name`, `name`, `tags`). Note: `location` is **not required** — Container Apps inherit location from their environment.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `container_app_environment_id` | string | Yes | — | Container Apps Environment ID |
| `revision_mode` | string | No | `"Single"` | Revision mode: `Single` or `Multiple` |
| `container` | object | Yes | — | Container configuration (see below) |
| `ingress` | object | No | `{}` | Ingress configuration (see below). Only used when `enable_ingress = true`. |
| `secrets` | map(string) | No | `{}` | Secrets. Key = secret name, value = secret value. |
| `scale` | object | No | `{}` | Scale configuration (see below) |
| `user_assigned_identity_ids` | list(string) | No | `[]` | User Assigned Identity IDs |
| `workload_profile_name` | string | No | `null` | Workload profile name (from the environment). `null` = Consumption. |
| `init_containers` | list(object) | No | `[]` | Init containers to run before the main container |

### Container Variable Structure

```hcl
variable "container" {
  type = object({
    image  = string
    cpu    = number    # e.g., 0.25, 0.5, 1.0, 2.0
    memory = string    # e.g., "0.5Gi", "1Gi", "2Gi"
    env = optional(map(object({
      value       = optional(string)
      secret_name = optional(string)
    })), {})
    liveness_probe = optional(object({
      transport               = string  # HTTP, HTTPS, TCP
      port                    = number
      path                    = optional(string)
      initial_delay           = optional(number, 1)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
    readiness_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
    startup_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
  })
  description = "Main container configuration."
}
```

### Ingress Variable Structure

```hcl
variable "ingress" {
  type = object({
    target_port = number
    transport   = optional(string, "auto")  # auto, http, http2, tcp
    traffic_weight = optional(object({
      latest_revision = optional(bool, true)
      percentage      = optional(number, 100)
    }), {})
  })
  default     = {}
  description = "Ingress configuration. Only used when enable_ingress = true."
}
```

### Scale Variable Structure

```hcl
variable "scale" {
  type = object({
    min_replicas = optional(number, 0)
    max_replicas = optional(number, 10)
    rules = optional(list(object({
      name = string
      http_scale_rule = optional(object({
        concurrent_requests = number
      }))
    })), [])
  })
  default     = {}
  description = "Scale configuration. Defaults to 0-10 replicas."
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `latest_revision_fqdn` | FQDN of the latest revision |
| `latest_revision_name` | Name of the latest revision |
| `outbound_ip_addresses` | Outbound IP addresses |
| `principal_id` | System-assigned managed identity principal ID (when enabled) |
| `tenant_id` | System-assigned managed identity tenant ID (when enabled) |
| `public_container_app_id` | Container app ID (public output) |
| `public_container_app_name` | Container app name (public output) |
| `public_container_app_fqdn` | Latest revision FQDN (public output) |

## Deferred

- **Multi-container (sidecars)** — The `template` block supports multiple containers. v1.0.0 focuses on single-container workloads. Add sidecar support in v1.1.0.
- **Volume mounts** — Azure Files, EmptyDir, and Secret volumes. Add when demand exists.
- **KEDA scaling rules** — Custom scale rules for Azure Queue, Service Bus, Cosmos DB, etc. v1.0.0 supports HTTP scaling only. Additional rules in v1.1.0.
- **Traffic splitting** — Requires `revision_mode = "Multiple"` and traffic weight configuration across named revisions. Complex pattern, defer.
- **Custom domains** — `azurerm_container_app_custom_domain` resource. Requires certificate management.
- **Dapr** — `dapr` block on the container app. Defer to project-level configuration.
- **IP restrictions** — `ip_security_restriction` blocks in ingress configuration.

## Notes

- **No `location` variable:** Container Apps inherit their location from the Container Apps Environment. The `location` standard interface variable is **not included** in this module. This is a documented deviation from the standard interface, same as `diagnostic-settings` and `private-dns-zone` modules.
- **Container name:** The container name within the template is derived from the module's `name` variable (sanitized for container naming rules). Consumers don't need to specify it separately.
- **CPU/memory combinations:** On Consumption plans, CPU and memory must match specific combinations (e.g., 0.25 CPU / 0.5Gi, 0.5 CPU / 1Gi, etc.). On dedicated workload profiles, these constraints are relaxed. The module does not validate combinations — Azure rejects invalid ones.
- **Secrets handling:** Secrets are passed as `map(string)` and stored in the container app. For Key Vault references, use the `identity` + `key_vault_secret_id` pattern in environment variables. This is a v1.1.0 enhancement.
- **Scale to zero:** Default `min_replicas = 0` allows scale to zero on Consumption plans. Set `min_replicas = 1` to keep at least one instance running (useful for reducing cold starts).
- **Naming:** CAF prefix for Container Apps is `ca`. Example: `ca-payments-api-dev-weu-001`.
- **Revision mode:** `Single` is simpler — only one revision is active. `Multiple` enables traffic splitting and blue/green deployments but requires more management. Default to `Single`.
