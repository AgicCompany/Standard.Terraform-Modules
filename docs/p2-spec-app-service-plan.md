# Module: app-service-plan

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_service_plan` — Azure App Service Plan (the hosting layer for web apps and function apps)

## v1.0.0 Scope

A service plan that provides the compute layer for Linux web apps and function apps. This is the `azurerm_service_plan` resource (the `azurerm_app_service_plan` resource was removed in AzureRM 4.x).

### In Scope

- Service plan creation with configurable SKU
- Linux OS type (hardcoded — this is a Linux-first organization)
- Configurable worker count
- Zone redundancy support via feature flag
- Per-app scaling support via feature flag

### Out of Scope (Deferred)

- Windows OS type (add as a variable override in a minor version if needed)
- App Service Environment (ASE) integration (Isolated SKUs)
- Elastic scale (Premium plan auto-scale) — consider for v1.1.0
- Flex Consumption plan — newer plan type, evaluate when stable

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_zone_redundancy` | `false` | Enable zone redundant deployment. Requires a Premium or higher SKU. |
| `enable_per_site_scaling` | `false` | Enable per-app scaling instead of scaling all apps on the plan together. |

## Private Endpoint Support

Not applicable. Service plans do not have private endpoints — the apps hosted on them do.

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sku_name` | string | Yes | — | The SKU for the plan (e.g., `B1`, `S1`, `P1v3`, `Y1`). See notes for valid values. |
| `worker_count` | number | No | `1` | Number of workers (instances) allocated to this plan. |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `kind` | The kind value of the service plan (e.g., `linux`) |
| `reserved` | Whether this is a Linux plan |
| `public_service_plan_id` | Service plan ID (public output for cross-project consumption) |

## Deferred

- **Windows support** — The `os_type` is hardcoded to `Linux`. If a project needs Windows, this becomes a variable in a minor version. Breaking change if we change the default, so it would need careful handling.
- **ASE integration** — `app_service_environment_id` variable for Isolated SKUs.
- **Auto-scale settings** — `premium_plan_auto_scale_enabled` property (available in recent AzureRM versions).
- **Maximum elastic worker count** — Relevant for Premium Elastic plans.

## Notes

- **AzureRM 4.x:** The old `azurerm_app_service_plan` resource was removed. Use `azurerm_service_plan`. Key differences: `os_type` replaces `kind` + `reserved`, and `sku_name` replaces the `sku` block with `tier` + `size`.
- **SKU values:** Valid `sku_name` values include: `B1`, `B2`, `B3` (Basic); `S1`, `S2`, `S3` (Standard); `P1v2`, `P2v2`, `P3v2` (Premium v2); `P1v3`, `P2v3`, `P3v3` (Premium v3); `Y1` (Consumption for Functions); `EP1`, `EP2`, `EP3` (Elastic Premium for Functions). The module does not validate SKU names — Azure will reject invalid values.
- **Consumption plans (`Y1`):** These are used for serverless Functions. Worker count and zone redundancy are not applicable for Consumption plans.
- **Zone redundancy:** Requires `sku_name` to be a Premium tier or higher (`P1v3`, etc.) and `worker_count >= 3`. The module does not enforce this — Azure will reject invalid combinations.
- **Naming:** CAF prefix for App Service Plans is `asp`. Example: `asp-payments-dev-weu-001`.
- **One plan, many apps:** A single service plan can host multiple web apps and function apps. The plan defines the compute; the apps define the workloads. This is a shared resource — consumers should plan for capacity accordingly.
- **Linux/Windows mixing:** Azure does not support mixing Linux and Windows apps in the same resource group (in some regions). This is an Azure limitation, not a module limitation. Document this in the README.
