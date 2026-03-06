# Terraform Modules Implementation Plan

**Version:** 1.1
**Status:** 36 modules complete — P0-P2 live-tested, P3 awaiting live tests
**Maintainer:** Infrastructure Team

This document is the implementation plan for the `terraform-modules` repository. It defines the order, scope, and workflow for building reusable Terraform modules following the organization's standards.

**Companion documents:**

- **Terraform Framework Specification** — project structure, naming, environments, CI/CD, governance
- **Module Standards** — module structure, variable conventions, defaults, outputs, versioning

This plan does not repeat what those documents define. It focuses on *what to build*, *in what order*, and *how to get each module from zero to released*.

---

## 1. Overview

The organization is building a library of reusable Terraform modules for Microsoft Azure. This is a greenfield effort — no existing modules or infrastructure to migrate from.

The module library will be hosted in a single monorepo (`terraform-modules`) with independent versioning per module. Projects consume modules remotely via Git tags, following the sourcing patterns defined in the Framework Specification.

### 1.1 Goals

- Deliver a foundational set of modules that cover the most common Azure resources
- Follow the Module Standards from day one — no "we'll clean it up later"
- Ship modules incrementally, prioritized by how broadly they are needed
- Establish cross-cutting patterns (private endpoints, diagnostic settings) early so they are consistent across all modules

### 1.2 Non-Goals

- Full Azure resource coverage — build what is needed, not a catalog of every possible resource
- Perfection before release — v1.0.0 covers the essential features; additional capabilities ship as minor versions
- Automation of everything — CI pipelines and advanced testing come after the initial modules are delivered

---

## 2. Guiding Principles

**Start simple, ship early.** A module that creates one resource well is more valuable than one that creates ten resources poorly. Every module ships with a v1.0.0 that covers the common use case. Edge cases and advanced features come in later minor releases.

**Secure by default.** Modules apply the most restrictive configuration unless the consumer explicitly overrides it. Private access is enabled, public access requires a deliberate flag. This follows the secure defaults philosophy in the Module Standards.

**Private first, public by choice.** All modules that support private endpoints ship with `enable_private_endpoint = true` by default. Public access is available via `enable_public_access = false` (default). See section 6.1 for the full pattern.

**Consistency over cleverness.** Every module follows the same file structure, variable organization, and output conventions. A developer who has used one module should feel at home in any other. No snowflakes, no "but this one is special."

**Iterate, don't accumulate.** Features that are deferred from v1.0.0 are documented in each module's spec under "Deferred." They are not forgotten — they are intentionally postponed. When a project needs them, they ship as a minor version bump.

**Document decisions.** Every module spec captures not just what was built, but what was deliberately excluded and why. Future-you (and future teammates) will thank past-you for this.

---

## 3. Module Inventory

### 3.1 Module Priority Matrix

| Priority | Module | Dependencies | Target Version | Status | Notes |
|----------|--------|--------------|----------------|--------|-------|
| P0 | storage-account | — | v1.0.0 | Released | Live-tested, 7 bugs fixed across all phases |
| P0 | key-vault | — | v1.0.0 | Released | Includes RBAC and secret management patterns in docs |
| P0 | virtual-network | — | v1.0.0 | Released | Subnets inline via map variable. Fixed `for_each` unknown-value bug. |
| P1 | network-security-group | — | v1.0.0 | Released | |
| P1 | log-analytics-workspace | — | v1.0.0 | Released | |
| P1 | diagnostic-settings | log-analytics-workspace | v1.0.0 | Released | Standalone module, applied selectively |
| P1 | user-assigned-identity | — | v1.0.0 | Released | |
| P1 | private-dns-zone | virtual-network | v1.0.0 | Released | Required by private endpoint pattern |
| P2 | app-service-plan | — | v1.0.0 | Released | Required by linux-web-app and function-app |
| P2 | linux-web-app | app-service-plan | v1.0.0 | Released | Fixed `health_check_eviction_time_in_min` for AzureRM 4.x |
| P2 | function-app | app-service-plan | v1.0.0 | Released | Fixed `application_stack` runtime conflict for AzureRM 4.x |
| P2 | container-app-environment | virtual-network, log-analytics-workspace | v1.0.0 | Released | Shared hosting layer for container apps |
| P2 | container-app | container-app-environment | v1.0.0 | Released | |
| P2 | container-registry | — | v1.0.0 | Released | |
| P2 | mssql-server | key-vault | v1.0.0 | Released | SQL blocked in westeurope for MPN — tested in northeurope |
| P2 | mssql-database | mssql-server | v1.0.0 | Released | |
| P2 | aks | virtual-network, container-registry | v1.0.0 | Released | ContainerInsights orphan on destroy — needs `az group delete` |
| P1 | nat-gateway | — | v1.0.0 | Complete | `terraform validate` passing. NAT GW + Standard public IP. |
| P1 | route-table | — | v1.0.0 | Complete | `terraform validate` passing. Routes as separate resources. |
| P1 | vnet-peering | — | v1.0.0 | Complete | `terraform validate` passing. Bidirectional peering. |
| P1 | application-insights | log-analytics-workspace | v1.0.0 | Complete | `terraform validate` passing. Workspace-based only. |
| P1 | action-group | — | v1.0.0 | Complete | `terraform validate` passing. Email/SMS/webhook/push receivers. |
| P2 | postgresql-flexible-server | — | v1.0.0 | Complete | `terraform validate` passing. VNet integration (not PE). |
| P2 | cosmosdb | — | v1.0.0 | Complete | `terraform validate` passing. SQL API + PE. |
| P3 | linux-virtual-machine | virtual-network | v1.0.0 | Released | Live-tested: apply + destroy clean. |
| P3 | windows-virtual-machine | virtual-network | v1.0.0 | Released | Live-tested: apply + destroy clean. |
| P3 | service-bus | — | v1.0.0 | Complete | `terraform validate` passing. Removed `zone_redundant` (AzureRM 4.x). |
| P3 | redis-cache | — | v1.0.0 | Complete | `terraform validate` passing. Awaiting live test. |
| P3 | front-door | — | v1.0.0 | Complete | `terraform validate` passing. Awaiting live test. |
| P3 | event-hub | — | v1.0.0 | Complete | `terraform validate` passing. Namespace + hubs + consumer groups + PE. |
| P3 | static-web-app | — | v1.0.0 | Complete | `terraform validate` passing. Free/Standard SKU. |
| P3 | bastion | virtual-network | v1.0.0 | Complete | `terraform validate` passing. Basic/Standard SKU. |
| P3 | mysql-flexible-server | — | v1.0.0 | Complete | `terraform validate` passing. VNet integration (not PE). |
| P3 | application-gateway | virtual-network | v1.0.0 | Complete | `terraform validate` passing. Standard_v2/WAF_v2, L7 routing. |
| P3 | api-management | — | v1.0.0 | Complete | `terraform validate` passing. VNet integration + PE. |
| P2 | aks-node-pool | aks | v1.0.0 | Complete | `terraform validate` passing. Node pool companion for AKS. Spot, GPU, Windows, autoscaling. |

### 3.2 Priority Definitions

| Priority | Meaning |
|----------|---------|
| P0 | Foundational — almost every project needs these, build first |
| P1 | Core infrastructure — needed for most real deployments |
| P2 | Application layer — needed once workloads are deployed (under review) |
| P3 | Situational — build when a project requires it |

### 3.3 Status Values

| Status | Meaning |
|--------|---------|
| Not Started | No work begun |
| In Progress | Implementation underway |
| Complete | Code complete, `terraform validate` passing, awaiting live test |
| Testing | Live testing in progress against Azure subscription |
| Released | Live-tested, tagged, and available for consumption |
| Backlog | Planned but not yet prioritized |

### 3.4 Dependency Notes

Most modules are independent. Notable dependencies:

- **diagnostic-settings** depends on a Log Analytics workspace existing. The `log-analytics-workspace` module should be released first or concurrently.
- **private-dns-zone** depends on a virtual network for zone linking. The `virtual-network` module should be released first.
- **app-service-plan** is required by both `linux-web-app` and `function-app`. Release it before or concurrently with those modules.
- **container-app-environment** is the shared hosting layer for container apps. It requires vnet integration and log analytics. Release it before or concurrently with `container-app`.
- **mssql-server** uses Key Vault for admin password retrieval. The `key-vault` module must be available.
- **mssql-database** is created within an MSSQL server. The `mssql-server` module must be available.
- **aks** touches networking, identity, and container registry. It has the broadest dependency surface and should be scoped and developed independently from the rest of P2 to avoid blocking other modules in the tier.

Dependencies refer to modules that should exist before the dependent module's examples can be meaningfully tested. They do not create hard build-order constraints — modules can be developed in parallel.

### 3.5 Provider Version Target

All modules target **AzureRM provider 4.x** (`>= 4.0.0`). The `versions.tf` standard in the Module Standards document should be updated to reflect this before implementation begins.

### 3.6 Tool Version Pinning

Tool versions (terraform-docs, tflint, tflint Azure ruleset) are pinned at the repository root level, not per module. Configuration files (`.tflint.hcl`, `.terraform-docs.yml`) are created during repository setup. This is handled when coding begins, not in this plan.

---

## 4. Module Specifications

Each module has a dedicated specification file in `docs/`. These files define the v1.0.0 scope, feature flags, variables, outputs, and deferred items for each module.

Files are prefixed with the module's current priority level. When a module's priority changes, the file is renamed to reflect the new priority.

**File naming convention:** `<priority>-spec-<module-name>.md`

**Specification files:**

| Module | Spec File |
|--------|-----------|
| storage-account | [p0-spec-storage-account.md](p0-spec-storage-account.md) |
| key-vault | [p0-spec-key-vault.md](p0-spec-key-vault.md) |
| virtual-network | [p0-spec-virtual-network.md](p0-spec-virtual-network.md) |
| network-security-group | [p1-spec-network-security-group.md](p1-spec-network-security-group.md) |
| log-analytics-workspace | [p1-spec-log-analytics-workspace.md](p1-spec-log-analytics-workspace.md) |
| diagnostic-settings | [p1-spec-diagnostic-settings.md](p1-spec-diagnostic-settings.md) |
| user-assigned-identity | [p1-spec-user-assigned-identity.md](p1-spec-user-assigned-identity.md) |
| private-dns-zone | [p1-spec-private-dns-zone.md](p1-spec-private-dns-zone.md) |
| app-service-plan | [p2-spec-app-service-plan.md](p2-spec-app-service-plan.md) |
| linux-web-app | [p2-spec-linux-web-app.md](p2-spec-linux-web-app.md) |
| function-app | [p2-spec-function-app.md](p2-spec-function-app.md) |
| container-app-environment | [p2-spec-container-app-environment.md](p2-spec-container-app-environment.md) |
| container-app | [p2-spec-container-app.md](p2-spec-container-app.md) |
| container-registry | [p2-spec-container-registry.md](p2-spec-container-registry.md) |
| mssql-server | [p2-spec-mssql-server.md](p2-spec-mssql-server.md) |
| mssql-database | [p2-spec-mssql-database.md](p2-spec-mssql-database.md) |
| aks | [p2-spec-aks.md](p2-spec-aks.md) |
| linux-virtual-machine | [p3-spec-linux-virtual-machine.md](p3-spec-linux-virtual-machine.md) |
| windows-virtual-machine | [p3-spec-windows-virtual-machine.md](p3-spec-windows-virtual-machine.md) |
| service-bus | [p3-spec-service-bus.md](p3-spec-service-bus.md) |
| redis-cache | [p3-spec-redis-cache.md](p3-spec-redis-cache.md) |
| front-door | [p3-spec-front-door.md](p3-spec-front-door.md) |
| nat-gateway | — (simple, no spec needed) |
| route-table | — (simple, no spec needed) |
| vnet-peering | — (simple, no spec needed) |
| application-insights | — (simple, no spec needed) |
| action-group | — (simple, no spec needed) |
| postgresql-flexible-server | — |
| cosmosdb | — |
| event-hub | — |
| static-web-app | — |
| bastion | — |
| mysql-flexible-server | — |
| application-gateway | — |
| api-management | — |

### 4.1 Module Spec Template

Each specification file follows this structure:

```markdown
# Module: <module-name>

**Priority:** P0 | P1 | P2 | P3
**Status:** Not Started | In Progress | Review | Released
**Target Version:** v1.0.0

## What It Creates

Resource(s) in scope for this module.

## v1.0.0 Scope

What ships in the first release.

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_*` | ... | ... |

## Private Endpoint Support

(If applicable) Subresource names, expected inputs.

## Variables

Key variables beyond the standard interface (resource_group_name, location, name, tags).

## Outputs

Key outputs beyond the standard interface (id, name).

## Deferred

What is explicitly out of scope for v1.0.0.

## Notes

Gotchas, Azure quirks, design decisions.
```

---

## 5. Implementation Workflow

This section defines how each module goes from "Not Started" to "Released." It references the processes defined in the Module Standards document and adds implementation-specific steps.

### 5.1 Per-Module Workflow

Each module follows this sequence:

**Step 1: Review the module spec.** Read the module's specification file in `docs/`. Understand the v1.0.0 scope, feature flags, and deferred items. If anything is unclear or missing, update the spec before writing code.

**Step 2: Scaffold the module.** Create the folder structure defined in Module Standards section 9. All files are created, including empty `locals.tf` and `data.tf` with comment headers.

**Step 3: Define the interface.** Write `versions.tf` and `variables.tf` first. Variables follow the grouping order from Module Standards section 2 (Required, Required Resource-Specific, Optional Configuration, Optional Feature Flags, Private Endpoint, Tags). This is the module's contract — get it right before implementing resources.

**Step 4: Implement resources.** Write `main.tf` with secure defaults as specified in the module spec. Apply the private endpoint pattern (section 6.1) if applicable. Use `locals.tf` for any computed values.

**Step 5: Define outputs.** Write `outputs.tf` following Module Standards section 4. Include `id` and `name` at minimum, plus resource-specific outputs listed in the module spec.

**Step 6: Write examples.** Create `examples/basic/` (required) and `examples/complete/` (recommended). Examples must be self-contained and use realistic values. The `complete/` example enables all feature flags and exercises the full interface.

**Step 7: Test.** Follow the pre-release checklist from Module Standards section 7:
1. `terraform fmt -recursive`
2. `terraform validate` in `examples/complete/`
3. Deploy `examples/complete/` to dev subscription
4. Verify resources created correctly
5. `terraform destroy` to confirm clean teardown

**Step 8: Document.** Write the module `README.md` following the template in Module Standards section 5. Run `terraform-docs` to generate the Inputs and Outputs tables. Initialize `CHANGELOG.md` with the v1.0.0 entry.

**Step 9: Release.** Create and push the Git tag:
```bash
git tag <module-name>/v1.0.0
git push origin <module-name>/v1.0.0
```

**Step 10: Update status.** Update the module's spec file status to "Released" and update the priority matrix in this document.

### 5.2 Batch Strategy

Modules within the same priority tier can be developed in parallel. The recommended approach:

1. Complete all P0 modules before starting P1
2. Within a tier, start with the module that has the fewest dependencies
3. If a module is blocked (waiting on a dependency), move to the next one in the tier

This is a guideline, not a hard rule. If a P1 module is trivial and a P0 module is complex, interleaving is fine.

### 5.3 Repository Setup

Before building the first module, the `terraform-modules` repository needs:

- Repository root `README.md` listing all available modules
- `.gitignore` at repository root (covers all modules)
- `.terraform-docs.yml` at repository root (shared terraform-docs configuration)

These are one-time setup tasks.

---

## 6. Cross-Cutting Patterns

These patterns apply across multiple modules and are documented here once rather than repeated in each module spec.

### 6.1 Public Outputs Pattern

All modules include `public_` prefixed outputs for cross-project state consumption (see Framework Specification section 21.2). These outputs are used by other projects via `terraform_remote_state` data sources.

Every module outputs at minimum:

| Output | Description |
|--------|-------------|
| `public_<resource>_id` | Resource ID |
| `public_<resource>_name` | Resource name |

Plus resource-specific outputs that other projects are likely to reference (e.g., `public_vnet_id`, `public_subnet_ids`, `public_vault_uri`).

Document all public outputs in each module's README under a **Public Outputs** section.

### 6.2 Private Endpoint Pattern

Private access is the default for all applicable modules. Public access is available via feature flag.

#### Interface

Each module that supports private endpoints includes these variables:

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `enable_private_endpoint` | bool | No | `true` | Create a private endpoint for this resource |
| `enable_public_access` | bool | No | `false` | Allow public network access |
| `subnet_id` | string | Conditional | — | Subnet ID for the private endpoint. Required when `enable_private_endpoint = true` |
| `private_dns_zone_id` | string | Conditional | — | Private DNS zone ID for DNS registration. Required when `enable_private_endpoint = true` |

#### Responsibility Split

| Concern | Managed By |
|---------|------------|
| Private endpoint resource | Module |
| Private DNS zone group | Module |
| Private DNS zone | Network project / consumer |
| Subnet | Network project / consumer |

The module creates the `azurerm_private_endpoint` and `azurerm_private_endpoint_dns_zone_group`. It does not create or manage the private DNS zone or subnet — these are shared resources managed at the network layer.

#### Subresource Names

Each module's spec file documents the Azure `subresource_names` value for its resource type. Examples:

| Module | Subresource Name |
|--------|-----------------|
| storage-account | `blob`, `file`, `table`, `queue` |
| key-vault | `vault` |
| mssql-server | `sqlServer` |
| container-registry | `registry` |
| linux-web-app | `sites` |
| function-app | `sites` |
| service-bus | `namespace` |
| redis-cache | `redisCache` |
| event-hub | `namespace` |
| cosmosdb | `Sql` |
| api-management | `Gateway` |

#### Outputs

Modules with private endpoint support include:

| Output | Description |
|--------|-------------|
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address assigned to the endpoint (when enabled) |

#### Validation

Modules should include validation to ensure `subnet_id` and `private_dns_zone_id` are provided when `enable_private_endpoint = true`. Use Terraform variable validation blocks or preconditions.

### 6.3 Diagnostic Settings Pattern

Diagnostic settings are handled by a standalone `diagnostic-settings` module, not baked into individual resource modules.

#### Rationale

Diagnostic settings are applied selectively to specific high-value resources (application gateways, firewalls, AKS clusters), not to every resource. A standalone module avoids adding unused complexity to resource modules that rarely need diagnostics.

#### Interface

The `diagnostic-settings` module accepts:

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | string | Yes | Diagnostic setting name |
| `target_resource_id` | string | Yes | Resource ID to monitor |
| `log_analytics_workspace_id` | string | Yes | Destination workspace |
| `enabled_log_categories` | list(string) | No | Specific log categories to enable (default: all) |
| `metric_categories` | list(string) | No | Specific metric categories to enable (default: all) |
| `tags` | map(string) | No | Tags |

#### Consumer Usage Example

```hcl
module "appgw_diagnostics" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/diagnostic-settings?ref=diagnostic-settings/v1.0.0"

  name                       = "diag-appgw-payments-dev-weu-001"
  target_resource_id         = module.application_gateway.id
  log_analytics_workspace_id = module.log_analytics.id
}
```

For multiple resources, consumers can use `for_each` at the project level:

```hcl
locals {
  monitored_resources = {
    appgw    = module.application_gateway.id
    firewall = module.firewall.id
  }
}

module "diagnostics" {
  for_each = local.monitored_resources
  source   = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/diagnostic-settings?ref=diagnostic-settings/v1.0.0"

  name                       = "diag-${each.key}-${var.project}-${var.environment}-${var.region_short}-001"
  target_resource_id         = each.value
  log_analytics_workspace_id = module.log_analytics.id
}
```

---

## 7. Open Questions

| # | Question | Status | Resolution |
|---|----------|--------|------------|
| 1 | P2 module list — review pending. | Resolved | Final P2 list: app-service-plan, linux-web-app, function-app, container-app-environment, container-app, container-registry, mssql-server, mssql-database, aks. Role-assignment dropped (too thin). Key-vault-secret and key-vault-access-policy dropped (too thin / deprecated); RBAC patterns documented in key-vault module spec instead. |
| 2 | Private endpoint: for storage accounts, should v1.0.0 support all subresource types (blob, file, table, queue) or just blob? | Resolved | All four subresource types (blob, file, table, queue) in v1.0.0. |
| 3 | Should the `virtual-network` module manage subnets inline or should subnets be a separate module? | Resolved | Inline via `subnets` map variable (Option C). Module outputs vnet name/ID for consumers who need to manage subnets independently. A standalone subnet module can be extracted later if demand materializes. |
| 4 | AKS v1.0.0 scope — what is the minimum viable feature set? Needs dedicated scoping discussion to avoid scope creep blocking the rest of P2. | Resolved | AKS v1.0.0 shipped with: private cluster, Azure CNI Overlay, AzureLinux nodes, system-assigned identity, OIDC, Azure RBAC, Container Insights, configurable default node pool. Live-tested and passing. ContainerInsights orphan on destroy is a known Azure issue — requires `az group delete`. |
| 5 | AzureRM provider 4.x — Module Standards document `versions.tf` example still references `>= 3.75.0`. Update needed before implementation begins. | Resolved | All 21 modules target `azurerm >= 4.0.0`. Multiple AzureRM 4.x breaking changes caught and fixed during live testing (see TEST_RESULTS.md). |

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | — | Initial skeleton |
| 0.2 | — | Fleshed out sections 1, 2, 5, 6. Added dependency notes and open questions. |
| 0.3 | — | Finalized module inventory. Added P1: private-dns-zone. Added P2: app-service-plan, function-app, container-app, container-registry, aks. Added P3: service-bus, redis-cache, front-door. Dropped role-assignment, key-vault-secret, key-vault-access-policy. Resolved open questions 1-3. Added AKS scoping as open question 4. |
| 0.4 | — | Added container-app-environment (P2). Set provider target to AzureRM 4.x. Added tool version pinning policy. Flagged Module Standards update needed for provider version. |
| 0.5 | — | Added public outputs as cross-cutting pattern (section 6.1). Completed P0 module specs (storage-account, key-vault, virtual-network). Completed P1 module specs (network-security-group, log-analytics-workspace, diagnostic-settings, user-assigned-identity, private-dns-zone). |
| 0.6 | — | Completed P2 module specs (app-service-plan, linux-web-app, function-app, container-app-environment, container-app, container-registry, mssql-server, mssql-database, aks). |
| 0.7 | — | All P0–P2 modules (17) implemented, live-tested, and passing. 4 integration stacks passing. 7 bugs fixed during live testing. |
| 1.0 | 2026-02-09 | All P3 modules (service-bus, redis-cache, linux-virtual-machine, front-door) implemented. All 21 modules code-complete. P0–P2 live-tested and released. P3 `terraform validate` passing, live testing starting with linux-virtual-machine. Resolved all open questions. |
| 1.1 | 2026-02-10 | Expanded framework to 35 modules. Added P1: nat-gateway, route-table, vnet-peering, application-insights, action-group. Added P2: postgresql-flexible-server, cosmosdb. Added P3: event-hub, static-web-app, bastion, mysql-flexible-server, application-gateway, api-management. windows-virtual-machine added in prior session. All new modules `terraform validate` passing. |
