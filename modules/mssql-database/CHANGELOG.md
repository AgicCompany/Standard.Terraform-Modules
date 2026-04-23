# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Database creation on existing SQL server
- Configurable SKU (DTU and vCore models)
- Short-term backup retention
- Geo-redundant backup (enabled by default)
- Zone redundancy support
- Read scale support
- License type configuration (Azure Hybrid Benefit)
