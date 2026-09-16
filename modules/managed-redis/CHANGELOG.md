# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.2.1] - 2026-09-16

### Fixed

- `diagnostic_settings` validation crashed `terraform plan` on Terraform 1.10–1.12 (which do not short-circuit `||` in validation conditions) whenever a sink was set without `log_analytics_destination_type`. Rewritten as nested ternaries; no interface or behavior change.
- `customer_managed_key` precondition crashed `terraform plan` on Terraform 1.10–1.12 whenever `identity` was left at its `null` default (i.e. the default configuration). Rewritten as nested ternaries; no interface or behavior change.

### Added

- Offline `terraform test` regression suite (`tests/validation.tftest.hcl`, mocked provider).

### Changed

- Internal: moved the `azurerm_monitor_diagnostic_categories` data source from `main.tf` to `data.tf` for file-structure consistency. No interface or behavior change.
- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.2.0] - 2026-04-25

### Added

- Precondition: customer-managed key now validates that a UserAssigned identity is configured.

## [1.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [1.0.0] - 2026-03-31

### Added

- Initial release
- Azure Managed Redis with configurable SKU (Balanced, ComputeOptimized, MemoryOptimized)
- Database configuration (clustering policy, eviction policy, client protocol)
- Redis modules support (RediSearch, RedisJSON, RedisBloom, RedisTimeSeries)
- Active-active geo-replication via group name
- Data persistence (AOF or RDB, mutually exclusive)
- Managed identity and customer-managed key support
- Private endpoint support with configurable naming
- Secure defaults (Encrypted protocol, Entra ID auth, PE enabled, public access disabled, HA enabled)
- Validation and preconditions for Azure constraints (RediSearch requirements, geo-replication compatibility, persistence exclusivity)
