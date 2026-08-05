# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Log Analytics workspace creation with configurable SKU
- Data retention with validation (30-730 days)
- Daily ingestion quota configuration
- Internet ingestion and query access controls (disabled by default)
- Standard outputs: `id`, `name`, `workspace_id`
- Public outputs for cross-project consumption
