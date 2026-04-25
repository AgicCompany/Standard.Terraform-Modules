# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- Precondition: VNet integration (External/Internal) now requires Premium SKU.
- Precondition: VNet integration and private endpoint are mutually exclusive.

## [2.2.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [2.1.0] - 2026-04-15

### Fixed

- Added `security` block explicitly disabling SSL 3.0, TLS 1.0, and TLS 1.1 on both frontend and backend
- Migrated deprecated `enable_*` security attributes to `*_enabled` (AzureRM v5.0 compatibility)

## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name

## [1.0.0] - 2026-02-10

### Added

- Initial release
- API Management service creation with configurable SKU
- VNet integration (External and Internal modes)
- Multi-region deployment support (Premium SKU)
- Availability zones support (Premium SKU)
- Private endpoint support for `Gateway` subresource
- System-assigned and user-assigned managed identity support
- Client certificate authentication
- Configurable notification sender email and minimum API version
- Secure defaults (public access disabled, PE enabled, SystemAssigned identity)
- Standard outputs: `id`, `name`, `gateway_url`, `management_api_url`, `developer_portal_url`
- Identity outputs: `principal_id`, `tenant_id`
- Private endpoint outputs: `private_endpoint_id`, `private_ip_address`
- Public outputs for cross-project consumption
