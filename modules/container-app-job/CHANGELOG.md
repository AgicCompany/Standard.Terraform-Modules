# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-06-05

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.
- `data.tf` with the `azurerm_monitor_diagnostic_categories` data source backing the above.

## [1.0.0] - 2026-05-29

### Added

- Initial release
- Container App Job creation in existing environment
- Three trigger types: event (KEDA scale rules), manual, and schedule (cron)
- Single container template with CPU/memory, env vars, command/args, and health probes
- Init containers
- Secrets: plain value and Azure Key Vault reference
- Private registry authentication via managed identity or username/password
- System and user-assigned managed identity
- `enable_secret_ignore_changes` feature flag (default `true`) to ignore secret changes after
  initial creation — recommended for secrets rotated outside Terraform
