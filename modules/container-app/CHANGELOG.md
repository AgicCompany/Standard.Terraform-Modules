# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.2.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [1.1.0] - 2026-02-19

### Added

- Enum validation on `ingress.transport` (auto, http, http2, tcp)
- Lifecycle preconditions for ingress and traffic-weight constraints

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Container App creation in existing environment
- Single container template with CPU/memory configuration
- HTTP/TCP ingress with external/internal toggle
- Environment variables and secret references
- System and user-assigned managed identity
- HTTP scale rules
- Init containers
- Liveness, readiness, and startup probes
