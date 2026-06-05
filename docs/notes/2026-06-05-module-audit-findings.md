---
title: Full-library module audit findings (41 modules)
date: 2026-06-05
status: draft
---

# Module Audit Findings — 2026-06-05

Read-only review of all 41 modules under `modules/` against `CLAUDE.md` +
`docs/MODULE_STANDARDS.md` (interface contract, secure defaults, feature-flag
conventions, validation, required files, AzureRM 4.x correctness). HIGH/security
items were hand-verified after review.

**Nothing fixed yet — this is a backlog.**

Baseline: no module outputs secrets; all `versions.tf` are correct
(`>= 1.10.0` / `>= 4.0.0`, no provider blocks); all required files present
except where noted.

## Secure-default gaps (highest priority — MAJOR bump each when fixed)

| # | Module | Finding | Fix |
|---|--------|---------|-----|
| 1 | mysql-flexible-server | `public_network_access_enabled` never set in `main.tf`. In PE mode (`enable_private_endpoint=true`, `delegated_subnet_id=null`) the server is created **public** by Azure default; PE added but public access stays on. **VERIFIED.** | Set `public_network_access_enabled = false` when not delegating. |
| 2 | function-app-flex | No `public_network_access_enabled` and no `enable_public_access` flag at all → defaults public. Sibling `function-app` has `enable_public_access=false`. **VERIFIED.** | Add `enable_public_access` (default false), wire to resource. |
| 3 | cosmosdb | `is_virtual_network_filter_enabled = false` hardcoded (`main.tf:13`); consumers can't restrict by VNet/subnet despite `ip_range_filter` existing. | Derive from ACLs or expose a variable. |

## Correctness / functional traps

| # | Module | Finding | Fix |
|---|--------|---------|-----|
| 4 | container-app-environment | Default `enable_internal_load_balancer=true` + `infrastructure_subnet_id=null` fails the module's OWN validation. Minimum-viable path (3 required vars + LAW) unreachable without overriding the flag. | Default flag false, or make subnet truly required. |
| 5 | container-app-job | Missing `data.tf` (required file) AND no `diagnostic_settings` support, despite creation 2026-05-29 (after the 2026-04-18 diagnostics cutoff). Sibling container-app has it. **VERIFIED.** | Add `data.tf` + standard `diagnostic_settings` variable/data/resource. |
| 6 | network-security-group | Protocol validation allows only `Tcp/Udp/Icmp/*`, rejects `Esp`/`Ah` which Azure accepts and the CHANGELOG claims are supported. | Add `Esp`, `Ah` to allowed list. |
| 7 | linux-web-app | Hardcoded `minimum_tls_version = "1.2"`, missing canonical `min_tls_version` var. Also `for_each = nonsensitive(var.connection_strings)` (`main.tf:45`) — but provider re-marks `value` sensitive in schema, so VALUES stay redacted; only names/types leak → **LOW**, not a secret leak. | Add `min_tls_version` var; iterate over keys for the cleaner pattern. |

## Interface-contract / ordering violations (MEDIUM)

- **aks** — `user_assigned_identity_ids` + `diagnostic_settings` (config) appear
  AFTER the feature-flags header in `variables.tf`. Should precede it.
- **postgresql-flexible-server** — same: private-networking/PE/diagnostics config
  blocks sit after the `enable_*` flag group.

## Documentation / release-process issues

- **static-web-app** — README "Security Defaults" table WRONG: says public Enabled
  / PE Disabled, but v3.0.0 defaults private (`enable_public_access=false`,
  `enable_private_endpoint=true`). CHANGELOG also lists `[2.1.0]` (2026-04-25)
  above `[3.0.0]` (2026-04-18) — ordering broken.
- **linux-virtual-machine** — CHANGELOG `[1.3.0]` is a verbatim duplicate of
  `[1.2.0]`; real 1.3.0 change undocumented.
- **windows-virtual-machine** — CHANGELOG `[2.0.0]` duplicates `[1.2.0]`'s "Added"
  block (both dated 2026-06-05); actual breaking content buried.
- **mysql-flexible-server** — CHANGELOG `[3.0.1] Fixed` FALSELY claims
  `enable_public_access` was wired to `public_network_access_enabled` (never was;
  later deprecated as no-op). `basic` example still sets `enable_public_access=true`
  (no-op, misleading).
- **api-management** — CHANGELOG documents `[2.1.0]` (TLS hardening) but no
  `api-management/v2.1.0` git tag exists (tags jump 2.0.0 → 2.2.0 → 2.3.0).

## Systemic (LOW, repo-wide)

- Most `examples/*/main.tf` pin `required_version = ">= 1.9.0"` while modules
  require `>= 1.10.0`. Single sweep fix.
- `public_*` output aliases (e.g. `public_aks_id` duplicating `id`) in ~8 modules,
  not in `MODULE_STANDARDS.md`. Codify the convention or drop them.
- `azurerm_monitor_diagnostic_categories` data source in `main.tf` while `data.tf`
  is an empty placeholder, in ~10 modules. Cosmetic.
- Non-`enable_` feature-flag naming in bastion, vnet-peering, static-web-app,
  managed-redis — mostly mirror provider arg names; renaming would be breaking.

## Clean (cosmetic notes only)

action-group, application-insights, app-service-plan, diagnostic-settings,
event-hub, front-door, function-app, key-vault, log-analytics-workspace,
managed-redis, mssql-database, mssql-server, nat-gateway, private-dns-zone,
redis-cache, route-table, service-bus, storage-account, user-assigned-identity,
virtual-network, vnet-peering.

## Versioning impact when fixing

- #1–#3 change runtime security posture → **MAJOR** bump each.
- False/duplicated CHANGELOG entries → patch bump.
- Ordering / example-version sweeps → patch / no-op.
