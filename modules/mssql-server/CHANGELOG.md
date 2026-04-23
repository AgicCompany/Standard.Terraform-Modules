# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [3.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [3.0.0] - 2026-04-18

### Changed

- **BREAKING**: `minimum_tls_version` variable renamed to `min_tls_version` for consistency with the canonical naming across the module library. Value format (`"1.2"`) is unchanged. The provider field name (`minimum_tls_version`) remains the same internally.
- **BREAKING**: `administrator_login_password` now enforces complexity when non-null (min 12 chars, must include upper, lower, digit, and symbol). Existing AAD-only deployments (password == null) are unaffected. Rejects weak passwords at validate time instead of forwarding to Azure.

### Migration

- Consumers passing `minimum_tls_version = ...` must rename the argument to `min_tls_version = ...`. No value change needed.
- Consumers passing `administrator_login_password` must ensure the value meets complexity rules (12+ chars; upper + lower + digit + symbol). AAD-only deployments that pass null are unaffected.

### Security

- Password complexity validation aligns with Azure's built-in SQL server rules.

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
- SQL logical server creation
- Azure AD administrator configuration
- Azure AD-only authentication (default)
- Private endpoint support
- System-assigned managed identity
- Configurable connection policy
- Secure defaults (TLS 1.2, public access disabled)
