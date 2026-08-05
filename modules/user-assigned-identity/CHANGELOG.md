# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.0] - 2026-02-08

### Added

- Initial release
- User-assigned managed identity creation
- Standard outputs: `id`, `name`, `principal_id`, `client_id`, `tenant_id`
- Public outputs for cross-project consumption
