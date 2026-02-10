# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Route table creation with BGP route propagation control
- Routes as separate `azurerm_route` resources via `for_each` map
- Support for all next hop types
- Validation: `next_hop_in_ip_address` required for VirtualAppliance
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
