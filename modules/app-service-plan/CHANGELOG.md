# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.1] - 2026-06-05

### Fixed

- Moved `os_type` variable from Required to Optional Configuration section (has default value "Linux").

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Service plan creation with configurable SKU
- Linux OS type (hardcoded)
- Configurable worker count
- Zone redundancy support
- Per-app scaling support
