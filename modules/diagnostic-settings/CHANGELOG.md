# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.1] - 2026-04-25

### Changed
- Improved descriptions for `enabled_log_categories` and `metric_categories` to document the allLogs/AllMetrics fallback behavior.

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Diagnostic setting creation targeting Log Analytics workspace
- All log categories enabled by default via `allLogs` category group
- All metric categories enabled by default via `AllMetrics` category group
- Selective log and metric category configuration
- Resource-specific (Dedicated) table support
- Standard outputs: `id`, `name`
