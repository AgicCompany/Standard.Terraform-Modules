# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [3.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [3.0.0] - 2026-04-18

### Changed

- **BREAKING**: `minimal_tls_version` variable renamed to `min_tls_version` for consistency with the canonical naming across the module library.
- **BREAKING**: Accepted value changed from `"Tls12"` to `"1.2"`. The module translates internally to the provider's `"Tls12"` format, so the deployed resource is unchanged — only the consumer-facing value is different.

### Migration

- Consumers passing `minimal_tls_version = "Tls12"` must rename the argument AND change the value: `min_tls_version = "1.2"`.
- The deployed resource is unchanged — translation is internal — so this is purely an API-surface change for consumers.

### Fixed

- Private endpoint `subresource_names` now correctly uses `"MongoDB"` when `kind = "MongoDB"` instead of hardcoded `"Sql"`

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

### Fixed

- Private endpoint `subresource_names` consistency improvements
- Example and output cleanup for cross-module consistency

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Cosmos DB account with SQL API
- SQL database management via `for_each` map with autoscale support
- Configurable consistency policy
- Multi-region geo-replication with automatic failover
- Private endpoint with DNS zone integration
- Periodic and continuous backup policies
- IP firewall and authentication controls
- Standard outputs: `id`, `name`, `endpoint`
- Public outputs for cross-project consumption
