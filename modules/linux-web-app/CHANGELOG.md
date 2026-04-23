# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [2.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Linux web app creation on existing service plan
- Application stack support (Docker, .NET, Node.js, Python, Java, PHP)
- Private endpoint support for `sites` subresource
- VNet integration for outbound traffic
- System and user-assigned managed identity support
- Application settings and connection strings
- Health check and always-on configuration
- Secure defaults (HTTPS only, TLS 1.2, FTPS disabled, public access disabled)
- Standard outputs: `id`, `name`, `default_hostname`, `outbound_ip_addresses`
- Identity outputs: `principal_id`, `tenant_id`
- Private endpoint outputs: `private_endpoint_id`, `private_ip_address`
- Public outputs for cross-project consumption
