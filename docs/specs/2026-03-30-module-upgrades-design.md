# Module Upgrades Design — PE Naming, Front Door v1.1.0, Function App Flex v1.0.0

**Date:** 2026-03-30
**Status:** Approved
**Supersedes:** `docs/tmp/2026-03-29-frontdoor-module-upgrade-spec.md`, `docs/tmp/2026-03-29-function-app-fc1-spec.md`, `docs/tmp/2026-03-29-module-pe-naming-override-spec.md`

## Context

The DTQ project alignment (`docs/tmp/2026-03-29-dtq-terraform-alignment-design.md`) identified three gaps in the module library that block clean consumption of standard modules:

1. Private endpoint names are hardcoded as `pe-{name}`, which doesn't follow the Azure CAF abbreviation (`pep`) and prevents importing existing PEs with different names (ForceNew fields).
2. The Front Door module (v1.0.0) lacks custom domains, WAF, rule sets, Private Link on origins, and security policies.
3. No module exists for Flex Consumption (FC1) Function Apps (`azurerm_function_app_flex_consumption`).

## Implementation Strategy

Three parallel streams with no dependencies between them:

| Stream | Scope | Version Impact |
|--------|-------|---------------|
| PE Naming Override | 14 existing modules | Major bump (all 14) |
| Front Door | 1 module upgrade | v1.0.0 -> v1.1.0 |
| Function App Flex | New module | v1.0.0 |

---

## Stream 1: PE Naming Override

### Scope

All 14 modules that create `azurerm_private_endpoint` resources:

| Module | Current Version | New Version |
|--------|----------------|-------------|
| api-management | v1.0.0 | v2.0.0 |
| container-registry | v1.0.0 | v2.0.0 |
| cosmosdb | v1.1.0 | v2.0.0 |
| event-hub | v1.1.0 | v2.0.0 |
| function-app | v1.0.0 | v2.0.0 |
| key-vault | v1.0.0 | v2.0.0 |
| linux-web-app | v1.0.0 | v2.0.0 |
| mssql-server | v1.1.0 | v2.0.0 |
| mysql-flexible-server | v2.0.0 | v3.0.0 |
| postgresql-flexible-server | v2.0.0 | v3.0.0 |
| redis-cache | v1.1.0 | v2.0.0 |
| service-bus | v1.1.0 | v2.0.0 |
| static-web-app | v1.1.0 | v2.0.0 |
| storage-account | v1.1.0 | v2.0.0 |

### Breaking Changes

1. **PE resource name default** changes from `pe-{name}` to `pep-{name}` (CAF-compliant). ForceNew — existing PEs are destroyed and recreated unless consumers pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
2. **PE NIC name** changes from Azure auto-generated (`{pe-name}.nic.{guid}`) to deterministic `pep-{name}-nic`. ForceNew — same escape hatch via `private_endpoint_nic_name` override.
3. **PSC name default** stays `psc-{name}` (no CAF abbreviation for this sub-resource), but is now overridable.

### Variables Added (per module)

```hcl
# === Optional: Private Endpoint Overrides ===

variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint resource name. Defaults to pep-{name}."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}

variable "private_endpoint_nic_name" {
  type        = string
  default     = null
  description = "Override the PE network interface name. Defaults to pep-{name}-nic."
}
```

### PE Resource Changes (per module)

Template pattern — `<resource>.id` and `<subresource>` vary per module (e.g., `azurerm_redis_cache.this.id` / `"redisCache"`, `azurerm_key_vault.this.id` / `"vault"`). The DNS zone group and other fields remain as-is from each module's current implementation.

```hcl
resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = coalesce(var.private_endpoint_name, "pep-${var.name}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")

  private_service_connection {
    name                           = coalesce(var.private_service_connection_name, "psc-${var.name}")
    private_connection_resource_id = <resource>.id
    is_manual_connection           = false
    subresource_names              = [<subresource>]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = var.tags
}
```

Note: Existing modules use `private_dns_zone_id` (singular string). The new `function-app-flex` module (Stream 3) uses `private_dns_zone_ids` (list of strings) as an improved interface that supports multiple DNS zones. This is intentional — existing modules keep their current singular variable to avoid a second breaking change.

### Storage Account Exception

Storage account creates multiple PEs via `for_each` (blob, file, table, queue). Override variables are maps:

```hcl
variable "private_endpoint_names" {
  type        = map(string)
  default     = {}
  description = "Override PE names per subresource key. Defaults to pep-{name}-{subresource}."
}

variable "private_service_connection_names" {
  type        = map(string)
  default     = {}
  description = "Override PSC names per subresource key. Defaults to psc-{name}-{subresource}."
}

variable "private_endpoint_nic_names" {
  type        = map(string)
  default     = {}
  description = "Override PE NIC names per subresource key. Defaults to pep-{name}-{subresource}-nic."
}
```

Usage:

```hcl
name                          = lookup(var.private_endpoint_names, each.key, "pep-${var.name}-${each.key}")
custom_network_interface_name = lookup(var.private_endpoint_nic_names, each.key, "pep-${var.name}-${each.key}-nic")

private_service_connection {
  name = lookup(var.private_service_connection_names, each.key, "psc-${var.name}-${each.key}")
}
```

### Per-Module Deliverables

- Update `variables.tf` — add 3 override variables in a new `=== Optional: Private Endpoint Overrides ===` section
- Update `main.tf` — modify PE resource naming
- Update `CHANGELOG.md` — document breaking changes
- Regenerate `README.md` via terraform-docs
- Update examples if they hardcode PE names

---

## Stream 2: Front Door v1.1.0

### Rationale for Minor Bump (Not v2.0.0)

All changes are additive: new optional variables with defaults, new optional object fields, new outputs. No existing variable is renamed, removed, or has its default changed. Per the project versioning rules, this is a minor bump.

### New Variables

#### Custom Domains

```hcl
variable "custom_domains" {
  type = map(object({
    hostname         = string
    certificate_type = optional(string, "ManagedCertificate")
  }))
  default     = {}
  description = "Map of custom domains to attach to the Front Door profile."
}
```

#### WAF (Managed Rules Only)

```hcl
variable "waf" {
  type = object({
    name = string
    mode = optional(string, "Detection")
    managed_rules = optional(list(object({
      type    = string
      version = string
      action  = string
    })), [])
  })
  default     = null
  description = "WAF firewall policy configuration. Null disables WAF. Custom rules deferred to v1.2.0+."
}
```

Validation: `mode` must be `Detection` or `Prevention`.

#### Rule Sets

```hcl
variable "rule_sets" {
  type = map(object({
    rules = map(object({
      order = number
      conditions = optional(object({
        url_file_extension = optional(object({
          operator     = string
          match_values = list(string)
        }))
        request_header = optional(object({
          operator     = string
          header_name  = string
          match_values = list(string)
        }))
      }))
      actions = object({
        request_header_actions = optional(list(object({
          header_action = string
          header_name   = string
          value         = optional(string)
        })), [])
        response_header_actions = optional(list(object({
          header_action = string
          header_name   = string
          value         = optional(string)
        })), [])
        url_rewrite = optional(object({
          source_pattern          = string
          destination             = string
          preserve_unmatched_path = optional(bool, true)
        }))
        url_redirect = optional(object({
          redirect_type        = string
          redirect_protocol    = optional(string, "Https")
          destination_hostname = optional(string)
          destination_path     = optional(string)
        }))
      })
    }))
  }))
  default     = {}
  description = "Map of rule sets. Each rule set contains a map of rules."
}
```

#### Origin Extensions (added to existing object)

```hcl
# Added to the existing origins object type:
private_link = optional(object({
  target_id       = string
  location        = string
  request_message = optional(string, "AFD Private Link connection")
}))
```

The `location` must match the PLS region, not the AFD profile region. For Italy North PLS deployments, use `westeurope` (Italy North is not supported as an AFD Private Link location).

#### Route Extensions (added to existing object)

```hcl
# Added to the existing routes object type:
rule_set_keys             = optional(list(string), [])
custom_domain_keys        = optional(list(string), [])
compression_enabled       = optional(bool, false)
content_types_to_compress = optional(list(string), [])
```

Routes reference rule sets and custom domains by map key. The module resolves keys to IDs internally:

```hcl
cdn_frontdoor_rule_set_ids      = [for k in route.value.rule_set_keys : azurerm_cdn_frontdoor_rule_set.this[k].id]
cdn_frontdoor_custom_domain_ids = [for k in route.value.custom_domain_keys : azurerm_cdn_frontdoor_custom_domain.this[k].id]
```

### New Resources

| Resource | Condition |
|----------|-----------|
| `azurerm_cdn_frontdoor_custom_domain` | `for_each = var.custom_domains` |
| `azurerm_cdn_frontdoor_firewall_policy` | `count = var.waf != null ? 1 : 0` |
| `azurerm_cdn_frontdoor_rule_set` | `for_each = var.rule_sets` |
| `azurerm_cdn_frontdoor_rule` | `for_each` over flattened rule_sets.rules |
| `azurerm_cdn_frontdoor_security_policy` | `count = var.waf != null ? 1 : 0` |

#### Security Policy

Hardcodes `patterns_to_match = ["/*"]` — WAF applies to all traffic. Associates WAF with the endpoint and all custom domains. Depends on routes being created first (`depends_on = [azurerm_cdn_frontdoor_route.this]`).

#### Private Link on Origins

Dynamic block on the origin resource, only rendered when `origin.value.private_link != null`:

```hcl
dynamic "private_link" {
  for_each = origin.value.private_link != null ? [origin.value.private_link] : []
  content {
    private_link_target_id = private_link.value.target_id
    location               = private_link.value.location
    request_message        = private_link.value.request_message
  }
}
```

AFD Private Link connections are not auto-approved — consumers must approve manually via Portal or CLI after `terraform apply`.

### New Outputs

```hcl
output "custom_domain_ids" {
  value = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.id }
}

output "custom_domain_validation_tokens" {
  value = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.validation_token }
}

output "firewall_policy_id" {
  value = var.waf != null ? azurerm_cdn_frontdoor_firewall_policy.this[0].id : null
}

output "rule_set_ids" {
  value = { for k, v in azurerm_cdn_frontdoor_rule_set.this : k => v.id }
}
```

### Not In Scope (Deferred)

- WAF custom rules (rate limiting, IP blocklists, geo-filtering) — v1.2.0+
- Diagnostic settings — separate `diagnostic-settings` module handles this
- Custom TLS certificates from Key Vault — managed certificates only for now

### Deliverables

- Update `variables.tf`, `main.tf`, `outputs.tf`
- Update `CHANGELOG.md`
- Regenerate `README.md`
- Update `examples/basic/` and `examples/complete/`

---

## Stream 3: Function App Flex v1.0.0

### Rationale for Separate Module

`azurerm_function_app_flex_consumption` is a different Terraform resource type from `azurerm_linux_function_app` with an incompatible schema: different storage model, different capacity configuration, no traditional `site_config`. Merging into the existing `function-app` module would require heavy conditionals on two resource types, confusing variables, and double the test matrix. The repo precedent (e.g., `container-app` vs `container-app-environment`) supports separate modules for different resource types.

### Module Path

`modules/function-app-flex/`

### File Structure

```
modules/function-app-flex/
├── versions.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── CHANGELOG.md
├── README.md
└── examples/
    ├── basic/
    └── complete/
```

### Variables

#### Required

```hcl
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "name" {
  type        = string
  description = "Name of the Function App."
}
```

#### Required: Resource-Specific

```hcl
variable "service_plan_id" {
  type        = string
  description = "ID of the FC1 (sku_name = FC1) App Service Plan."
}

variable "runtime_name" {
  type        = string
  description = "Runtime stack: dotnet-isolated, python, node, java, powershell, or custom."
}

variable "runtime_version" {
  type        = string
  description = "Runtime version (e.g. '8.0' for dotnet-isolated, '3.11' for python)."
}

variable "storage_container_endpoint" {
  type        = string
  description = "URL of the blob container for deployment package storage."
}
```

#### Optional: Configuration

```hcl
variable "instance_memory_in_mb" {
  type        = number
  default     = 2048
  description = "Memory per instance in MB."

  validation {
    condition     = contains([512, 2048, 4096], var.instance_memory_in_mb)
    error_message = "Allowed values: 512, 2048, 4096."
  }
}

variable "maximum_instance_count" {
  type        = number
  default     = 10
  description = "Maximum number of instances for scaling."
}

variable "always_ready_instances" {
  type = map(object({
    instance_count = number
  }))
  default     = {}
  description = "Map of always-ready instance configurations keyed by function name."
}

variable "storage_container_type" {
  type        = string
  default     = "blobContainer"
  description = "Storage container type for FC1 deployment package."
}

variable "storage_authentication_type" {
  type        = string
  default     = "StorageAccountConnectionString"
  description = "Storage auth type: StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity."

  validation {
    condition     = contains(["StorageAccountConnectionString", "SystemAssignedIdentity", "UserAssignedIdentity"], var.storage_authentication_type)
    error_message = "Must be StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity."
  }
}

variable "storage_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "Resource ID of the user-assigned identity for storage auth. Required when storage_authentication_type = UserAssignedIdentity."
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "Application settings. Ignored on subsequent applies (managed by dev teams via CI/CD)."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration (outbound traffic)."
}
```

#### Optional: Identity

```hcl
variable "identity_type" {
  type        = string
  default     = "None"
  description = "Managed identity type: None, SystemAssigned, or UserAssigned."

  validation {
    condition     = contains(["None", "SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Must be None, SystemAssigned, or UserAssigned."
  }
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "List of user-assigned identity resource IDs. Required when identity_type = UserAssigned."
}
```

#### Optional: Security

```hcl
variable "https_only" {
  type        = bool
  default     = true
  description = "Require HTTPS connections."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "Client certificate mode: Required, Optional, or OptionalInteractiveUser."
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable basic authentication for web deploy."
}
```

#### Optional: Feature Flags

```hcl
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for the Function App."
}
```

#### Optional: Private Endpoint

```hcl
variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint = true."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs for the PE DNS zone group."
}

variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint resource name. Defaults to pep-{name}."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}

variable "private_endpoint_nic_name" {
  type        = string
  default     = null
  description = "Override the PE network interface name. Defaults to pep-{name}-nic."
}
```

#### Tags

```hcl
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources."
}
```

### Main Resource

```hcl
resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  https_only                                     = var.https_only
  client_certificate_mode                        = var.client_certificate_mode
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled

  virtual_network_subnet_id = var.virtual_network_subnet_id
  maximum_instance_count    = var.maximum_instance_count

  runtime_name                      = var.runtime_name
  runtime_version                   = var.runtime_version
  storage_container_type            = var.storage_container_type
  storage_container_endpoint        = var.storage_container_endpoint
  storage_authentication_type       = var.storage_authentication_type
  storage_user_assigned_identity_id = var.storage_user_assigned_identity_id

  instance_memory_in_mb = var.instance_memory_in_mb

  dynamic "always_ready" {
    for_each = var.always_ready_instances
    content {
      name           = always_ready.key
      instance_count = always_ready.value.instance_count
    }
  }

  app_settings = var.app_settings

  site_config {}

  dynamic "identity" {
    for_each = var.identity_type != "None" ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config,
      storage_container_endpoint,
      storage_access_key,
    ]
  }
}
```

### Private Endpoint

```hcl
resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = coalesce(var.private_endpoint_name, "pep-${var.name}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")

  private_service_connection {
    name                           = coalesce(var.private_service_connection_name, "psc-${var.name}")
    private_connection_resource_id = azurerm_function_app_flex_consumption.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}
```

### Preconditions

```hcl
lifecycle {
  precondition {
    condition     = !var.enable_private_endpoint || var.private_endpoint_subnet_id != null
    error_message = "private_endpoint_subnet_id is required when enable_private_endpoint is true."
  }
}
```

### Outputs

```hcl
output "id" {
  value       = azurerm_function_app_flex_consumption.this.id
  description = "Function App resource ID."
}

output "name" {
  value       = azurerm_function_app_flex_consumption.this.name
  description = "Function App name."
}

output "default_hostname" {
  value       = azurerm_function_app_flex_consumption.this.default_hostname
  description = "Default hostname of the Function App."
}

output "identity" {
  value       = azurerm_function_app_flex_consumption.this.identity
  description = "Managed identity block (principal_id, tenant_id)."
}

output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID."
}
```

### Lifecycle Ignore Changes Rationale

`app_settings`, `site_config`, `storage_container_endpoint`, and `storage_access_key` are ignored on subsequent applies. Terraform provisions the infrastructure shell; dev teams manage app configuration via CI/CD or Portal. Without this, every `terraform apply` would reset developer-managed settings.

---

## Modules NOT Affected by PE Sweep (Stream 1)

The following 22 modules have no `azurerm_private_endpoint` resource and are not touched by Stream 1. Note: `front-door` appears here because it has no PE resource — it is modified by Stream 2 (feature upgrade) instead.

action-group, aks, aks-node-pool, app-service-plan, application-gateway, application-insights, bastion, container-app, container-app-environment, diagnostic-settings, front-door, linux-virtual-machine, log-analytics-workspace, mssql-database, nat-gateway, network-security-group, private-dns-zone, route-table, user-assigned-identity, virtual-network, vnet-peering, windows-virtual-machine
