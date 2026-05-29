---
title: "New module: container-app-job wrapping azurerm_container_app_job"
date: 2026-05-29
status: draft
---

## Context

`IP.infrastructure-as-a-platform` currently defines an `azurerm_container_app_job` inline for
GitHub self-hosted runners. This spec describes a reusable `modules/container-app-job` module
that satisfies the reference implementation as its minimum contract while being general enough
for other trigger types and workloads.

Closes GitHub issue #43.

## Scope

- **In scope:** new `modules/container-app-job` module, `basic` and `complete` examples,
  CHANGELOG, README (auto-generated), initial `v1.0.0` tag
- **Out of scope:** diagnostic settings (can be added in a future minor), volumes/volume-mounts
  (not in the reference implementation, can be added later)

## File Structure

```
modules/container-app-job/
├── versions.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── CHANGELOG.md
├── README.md
└── examples/
    ├── basic/
    │   └── main.tf
    └── complete/
        └── main.tf
```

## Module Interface

### Required Variables

```hcl
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "name"                { type = string }

variable "container_app_environment_id" { type = string }

variable "replica_timeout_in_seconds" {
  type        = number
  description = "Maximum number of seconds a replica can run. Required by the provider."
}

variable "container" {
  type = object({
    image  = string
    cpu    = number
    memory = string
    env = optional(map(object({
      value       = optional(string)
      secret_name = optional(string)
    })), {})
    command = optional(list(string))
    args    = optional(list(string))
    liveness_probe = optional(object({
      transport               = string
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
      initial_delay           = optional(number, 1)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
    startup_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      initial_delay           = optional(number, 1)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
  })
}
```

### Optional: Configuration

```hcl
variable "workload_profile_name" {
  type    = string
  default = null
}

variable "replica_retry_limit" {
  type    = number
  default = null
}

variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}

variable "registries" {
  type = list(object({
    server               = string
    identity             = optional(string)
    username             = optional(string)
    password_secret_name = optional(string)
  }))
  default = []
  # Two validation blocks (identical to container-app v1.3.0):
  # 1. identity XOR (username AND password_secret_name)
  # 2. username and password_secret_name must be set together
}

variable "secrets" {
  type = map(object({
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))
  default   = {}
  sensitive = true
  # validation: value XOR key_vault_secret_id per entry
}

variable "init_containers" {
  type = list(object({
    image   = string
    name    = string
    cpu     = optional(number)
    memory  = optional(string)
    command = optional(list(string))
    args    = optional(list(string))
    env = optional(map(object({
      value       = optional(string)
      secret_name = optional(string)
    })), {})
  }))
  default = []
}
```

### Trigger Variables

Exactly one must be set. Enforced via a `check` block in `main.tf` (Terraform 1.8+, module
requires 1.10+). Variable-level `validation` blocks cannot reference other variables in
Terraform and are not used here.

```hcl
variable "event_trigger_config" {
  type = object({
    parallelism              = optional(number, 1)
    replica_completion_count = optional(number, 1)
    scale = optional(object({
      min_executions              = optional(number, 0)
      max_executions              = optional(number, 10)
      polling_interval_in_seconds = optional(number, 30)
      rules = optional(list(object({
        name             = string
        custom_rule_type = string
        identity_id      = optional(string)
        metadata         = map(string)
        authentication = optional(list(object({
          secret_name       = string
          trigger_parameter = string
        })), [])
      })), [])
    }), {})
  })
  default = null
}

variable "manual_trigger_config" {
  type = object({
    parallelism              = optional(number, 1)
    replica_completion_count = optional(number, 1)
  })
  default = null
}

variable "schedule_trigger_config" {
  type = object({
    cron_expression          = string
    parallelism              = optional(number, 1)
    replica_completion_count = optional(number, 1)
  })
  default = null
}
```

`check` block in `main.tf`:

```hcl
check "trigger_config_exactly_one" {
  assert {
    condition = length([
      for v in [
        var.event_trigger_config,
        var.manual_trigger_config,
        var.schedule_trigger_config
      ] : v if v != null
    ]) == 1
    error_message = "Exactly one of event_trigger_config, manual_trigger_config, or schedule_trigger_config must be set."
  }
}
```

### Optional: Feature Flags

```hcl
variable "enable_system_assigned_identity" {
  type    = bool
  default = false
}

variable "enable_secret_ignore_changes" {
  type        = bool
  default     = true
  description = "When true, Terraform ignores changes to the secret block after initial creation. Recommended for secrets rotated outside Terraform. WARNING: toggling this value after initial deployment will destroy and recreate the job resource."
}
```

### Tags

```hcl
variable "tags" {
  type    = map(string)
  default = {}
}
```

## locals.tf

```hcl
locals {
  identity_type = (
    var.enable_system_assigned_identity && length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.enable_system_assigned_identity ? "SystemAssigned" :
    length(var.user_assigned_identity_ids) > 0 ? "UserAssigned" :
    null
  )

  container_name = replace(lower(var.name), "/[^a-z0-9-]/", "")

  # Abstraction over the dual-resource pattern for lifecycle
  job = var.enable_secret_ignore_changes ? (
    azurerm_container_app_job.with_lifecycle[0]
  ) : (
    azurerm_container_app_job.without_lifecycle[0]
  )
}
```

## main.tf

Two `azurerm_container_app_job` resources, mutually exclusive via `count`, differing only in
the presence of `lifecycle { ignore_changes = [secret] }`. All blocks (`identity`, `registry`,
`secret`, `event_trigger_config`, `manual_trigger_config`, `schedule_trigger_config`, `template`)
are identical between the two resources and use `dynamic` blocks throughout.

A `check` block enforces that exactly one trigger config is set (see Trigger Variables above).

```hcl
check "trigger_config_exactly_one" {
  assert {
    condition = length([
      for v in [var.event_trigger_config, var.manual_trigger_config, var.schedule_trigger_config]
      : v if v != null
    ]) == 1
    error_message = "Exactly one of event_trigger_config, manual_trigger_config, or schedule_trigger_config must be set."
  }
}

resource "azurerm_container_app_job" "with_lifecycle" {
  count = var.enable_secret_ignore_changes ? 1 : 0
  # ... all blocks ...
  lifecycle { ignore_changes = [secret] }
}

resource "azurerm_container_app_job" "without_lifecycle" {
  count = var.enable_secret_ignore_changes ? 0 : 1
  # ... all blocks (identical) ...
}
```

## outputs.tf

```hcl
output "id"                    { value = local.job.id }
output "name"                  { value = local.job.name }
output "outbound_ip_addresses" { value = local.job.outbound_ip_addresses }
output "event_stream_endpoint" { value = local.job.event_stream_endpoint }
output "principal_id"          { value = try(local.job.identity[0].principal_id, null) }
output "tenant_id"             { value = try(local.job.identity[0].tenant_id, null) }
```

## Examples

### basic/main.tf

Minimum viable: event trigger with a GitHub runner scale rule, user-assigned identity,
private registry via managed identity. Mirrors the downstream reference implementation.

### complete/main.tf

All features: event trigger with custom scale rule + authentication, KV-referenced secret,
init container, `workload_profile_name`, `replica_retry_limit`.

## Versioning

Initial release: `v1.0.0`, tagged `container-app-job/v1.0.0`.

## Validation

Before tagging:

1. `make fmt MODULE=container-app-job`
2. `make validate MODULE=container-app-job`
3. `make lint MODULE=container-app-job`
4. `make docs`
5. Manual plan from `examples/complete`: `terraform init && terraform plan`
