---
title: "container-app: add registry support for private ACR pulls"
date: 2026-05-29
status: draft
---

## Context

The `modules/container-app` module correctly attaches user-assigned managed identities to a
Container App but does not emit a `registry {}` block. Azure Container Apps requires an explicit
`registry` block to authenticate against a private registry, even when the identity has `AcrPull`
assigned. Without it, image pulls fail with `401 Unauthorized` and the revision never starts —
the failure is silent because `az containerapp update --image` reports success regardless.

Closes GitHub issue #44.

## Scope

- **In scope:** add `registries` variable and `dynamic "registry"` block to `modules/container-app`
- **Out of scope:** public registries (no auth block needed), system-assigned identity as registry
  identity (use `enable_system_assigned_identity` flag separately), `modules/container-app-job`
  (tracked in issue #43, separate spec)

## Variable Design

New optional variable added under `# === Optional: Configuration ===` in `variables.tf`:

```hcl
variable "registries" {
  type = list(object({
    server               = string
    identity             = optional(string)
    username             = optional(string)
    password_secret_name = optional(string)
  }))
  default     = []
  description = "Private registry authentication. Each entry requires either 'identity' (resource ID of a user-assigned managed identity) or 'username' + 'password_secret_name'. The identity must be present in user_assigned_identity_ids."

  validation {
    condition = alltrue([
      for r in var.registries :
      (r.identity != null) != (r.username != null || r.password_secret_name != null)
    ])
    error_message = "Each registry entry must use either 'identity' or 'username'+'password_secret_name', not both and not neither."
  }
}
```

Notes:
- `identity` accepts the full resource ID of a user-assigned managed identity
- `username`/`password_secret_name` are for admin credential auth; `password_secret_name` must
  reference a key in `var.secrets`
- Supports multiple registry entries (e.g., two private ACRs in the same app)

## Resource Change

Dynamic block added to `azurerm_container_app.this` in `main.tf`, after the `identity` block:

```hcl
dynamic "registry" {
  for_each = var.registries

  content {
    server               = registry.value.server
    identity             = registry.value.identity
    username             = registry.value.username
    password_secret_name = registry.value.password_secret_name
  }
}
```

No other resources, outputs, or locals are affected.

## Examples

**`examples/basic/main.tf`** — no change. Uses a public image; no registry auth needed.

**`examples/complete/main.tf`** — add a user-assigned managed identity resource and demonstrate
managed identity registry auth:

```hcl
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-ca-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# (ACR resource omitted for brevity; consumer is expected to provide login_server)

module "container_app" {
  # ...existing config...

  user_assigned_identity_ids = [azurerm_user_assigned_identity.app.id]

  registries = [
    {
      server   = "myacr.azurecr.io"
      identity = azurerm_user_assigned_identity.app.id
    }
  ]
}
```

## Versioning

| Current | New    | Reason                                      |
|---------|--------|---------------------------------------------|
| 1.2.0   | 1.3.0  | New optional variable, backward compatible  |

Git tag: `container-app/v1.3.0`

## Changelog Entry

```md
## [1.3.0] - 2026-05-29

### Added

- `registries` variable (optional, default `[]`): list of private registry authentication entries.
  Supports managed identity auth (`identity` = user-assigned identity resource ID) and
  username/password auth (`username` + `password_secret_name`). Generates a `registry` block
  per entry on the Container App resource.
```

## Validation

Before tagging:

1. `make fmt MODULE=container-app`
2. `make validate MODULE=container-app`
3. `make lint MODULE=container-app`
4. `make docs`
5. Manual plan from `examples/complete`: `terraform init && terraform plan`
