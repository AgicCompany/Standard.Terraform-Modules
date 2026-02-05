# Module: user-assigned-identity

**Priority:** P1  
**Status:** Not Started  
**Target Version:** v1.0.0

## What It Creates

- `azurerm_user_assigned_identity` — Azure User-Assigned Managed Identity

## v1.0.0 Scope

A simple module for creating user-assigned managed identities. This is intentionally thin — the identity is created, and role assignments are handled by consumers at the project level.

### In Scope

- User-assigned managed identity creation

### Out of Scope (Deferred)

- Federated identity credentials (for workload identity federation with GitHub Actions, AKS, etc.)
- Role assignments (consumers create these directly using `azurerm_role_assignment`)

## Feature Flags

No feature flags for v1.0.0.

## Private Endpoint Support

Not applicable. Managed identities do not have private endpoints.

## Variables

Standard interface only (`resource_group_name`, `location`, `name`, `tags`). No additional variables needed.

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `principal_id` | Service principal ID associated with the identity |
| `client_id` | Client ID of the identity |
| `tenant_id` | Tenant ID of the identity |
| `public_identity_id` | Identity resource ID (for cross-project consumption) |
| `public_principal_id` | Principal ID (for cross-project role assignments) |
| `public_client_id` | Client ID (for cross-project application configuration) |

## Notes

- **Simplicity is intentional.** This module wraps a single resource. Its value is consistency (same interface, same file structure, same output conventions) rather than abstraction. A developer who has used one module should feel at home here.
- **Role assignments:** Consumers assign roles at the project level using `azurerm_role_assignment` with `principal_id` from this module's output. This keeps the identity and its permissions in the same Terraform state as the resources it accesses.
- **Federated identity credentials:** Deferred to a minor version. When AKS workload identity or GitHub Actions OIDC is needed, a `enable_federated_credentials` flag with a `federated_credentials` variable can be added without breaking changes.
