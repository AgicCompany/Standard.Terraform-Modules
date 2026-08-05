# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.2.0] - 2026-04-25

### Added

- Validation: next_hop_in_ip_address is now forbidden for non-VirtualAppliance hop types.

## [1.1.0] - 2026-02-19

### Added

- Enum validation on `routes[*].next_hop_type` (VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None)

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Route table creation with BGP route propagation control
- Routes as separate `azurerm_route` resources via `for_each` map
- Support for all next hop types
- Validation: `next_hop_in_ip_address` required for VirtualAppliance
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
