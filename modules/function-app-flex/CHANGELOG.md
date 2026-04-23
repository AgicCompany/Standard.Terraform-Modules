# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

### Fixed

- Added missing `locals.tf` and `data.tf` files per module file structure standard

## [1.0.0] - 2026-03-30

### Added

- Initial release
- Flex Consumption (FC1) Function App via `azurerm_function_app_flex_consumption`
- Configurable runtime, memory, scaling, and always-ready instances
- Flexible storage authentication (connection string, system identity, user identity)
- Managed identity support (SystemAssigned, UserAssigned)
- VNet integration for outbound traffic
- Private endpoint with CAF-compliant naming (`pep-{name}`) and override variables
- Secure defaults (HTTPS-only, client certificates required, basic auth disabled)
- Lifecycle ignore_changes on app_settings and site_config (infra shell pattern)
