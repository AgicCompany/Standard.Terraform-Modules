# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Virtual network creation with configurable address space
- Subnets via map variable with support for:
  - NSG association
  - Route table association
  - Service endpoints
  - Private endpoint network policies
  - Private link service network policies
  - Subnet delegation
- Standard outputs: `id`, `name`, `address_space`, `subnet_ids`, `subnet_address_prefixes`
- Public outputs for cross-project consumption
