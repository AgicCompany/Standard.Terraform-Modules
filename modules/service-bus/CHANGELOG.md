# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [3.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [3.0.0] - 2026-04-18

### Changed

- **BREAKING**: `minimum_tls_version` variable renamed to `min_tls_version` for consistency with the canonical naming across the module library. Value format (`"1.2"`) is unchanged. The module continues to set the provider's `minimum_tls_version` field internally; only the consumer-facing variable name changed.

### Migration

- Consumers passing `minimum_tls_version = ...` must rename the argument to `min_tls_version = ...`. Only `"1.2"` is accepted (unchanged); no value change needed.

## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name

## [1.1.0] - 2026-03-03

### Added

- Lifecycle preconditions and DNS zone group configuration for private endpoints
- `min_tls_version` validation enforcing `"1.2"` as minimum

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Service Bus namespace with configurable SKU (Basic, Standard, Premium)
- Queue management with for_each
- Topic and subscription management with for_each
- Private endpoint support
- Secure defaults (local auth disabled, public access disabled, TLS 1.2)
