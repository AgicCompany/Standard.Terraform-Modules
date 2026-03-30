# Module Private Endpoint Naming Override — Spec

## Problem

All modules in AgicCompany/Standard.Terraform-Modules hardcode PE and private service connection names:

```hcl
name = "pe-${var.name}"                    # PE resource name
name = "psc-${var.name}"                   # private_service_connection name
```

Both fields are ForceNew on `azurerm_private_endpoint` — changing them destroys and recreates the PE. This makes it impossible to import existing PEs that were created with different naming conventions (e.g., `redis-deghi-dtq-itn-01-pe` instead of `pe-redis-deghi-dtq-itn-01`).

## Affected Modules

| Module | PE name pattern | Connection name pattern |
|--------|----------------|------------------------|
| redis-cache | `pe-{name}` | `psc-{name}` |
| postgresql-flexible-server | `pe-{name}` | `psc-{name}` |
| container-registry | `pe-{name}` | `psc-{name}` |
| storage-account | `pe-{name}-{subresource}` | `psc-{name}-{subresource}` |
| service-bus | `pe-{name}` | `psc-{name}` |

## Proposed Fix

Add two optional variables to every module that creates a private endpoint:

```hcl
variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint resource name. Defaults to pe-{name}."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}
```

Usage in the PE resource:

```hcl
resource "azurerm_private_endpoint" "this" {
  name = coalesce(var.private_endpoint_name, "pe-${var.name}")
  ...

  private_service_connection {
    name = coalesce(var.private_service_connection_name, "psc-${var.name}")
    ...
  }
}
```

For storage-account (multi-PE), the override should be a map:

```hcl
variable "private_endpoint_names" {
  type        = map(string)
  default     = {}
  description = "Override PE names per subresource. Keys: blob, file, table, queue."
}
```

## Impact

- Non-breaking: defaults preserve current behavior
- Enables import of existing PEs with non-standard names
- Minor version bump (new optional variables) for each affected module

## Priority

Medium — blocks clean import of existing infrastructure. Required before any production import where PEs were created outside these modules.
