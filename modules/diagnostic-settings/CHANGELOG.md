# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
