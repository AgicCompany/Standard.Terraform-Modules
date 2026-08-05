# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.0] - 2026-02-09

### Added

- Initial release
- NAT gateway with Standard SKU
- Public IP creation and association
- Configurable idle timeout
- Availability zone support
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
