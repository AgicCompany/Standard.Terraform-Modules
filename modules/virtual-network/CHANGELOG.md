# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
