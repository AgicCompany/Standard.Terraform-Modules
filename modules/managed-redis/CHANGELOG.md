# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
