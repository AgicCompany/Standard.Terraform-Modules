# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [2.0.0] - 2026-04-24

### Removed
- **BREAKING:** Removed `instrumentation_key`, `connection_string`, and `public_connection_string` outputs. Retrieve via `data.azurerm_application_insights` or Key Vault references instead.

### Fixed
- Updated examples to remove references to deleted `connection_string` output.

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Workspace-based Application Insights
- Configurable application type, retention, daily cap, sampling
- Local authentication toggle
- Connection string and instrumentation key as sensitive outputs
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
