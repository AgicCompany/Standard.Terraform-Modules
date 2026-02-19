# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [2.0.0] - 2026-02-19

### Added

- Private endpoint support (`enable_private_endpoint`, `subnet_id`) as alternative to VNet delegation
- PE outputs: `private_endpoint_id`, `private_ip_address`
- Mutual exclusion precondition: PE and delegation cannot be used simultaneously

### Changed

- **BREAKING:** `enable_private_endpoint` defaults to `true` — existing consumers using delegation must explicitly set `enable_private_endpoint = false`
- `private_dns_zone_id` is now required when either delegation or PE is used (was only required for delegation)
- Renamed VNet Integration section to Private Networking

## [1.0.0] - 2026-02-09

### Added

- Initial release
- PostgreSQL Flexible Server with configurable SKU, version, and storage
- Database management via `for_each` map
- Server configuration parameters via `for_each` map
- Firewall rules via `for_each` map
- VNet integration via delegated subnet
- High availability support (SameZone / ZoneRedundant)
- Custom maintenance window
- Entra ID authentication support
- Standard outputs: `id`, `name`, `fqdn`
- Public outputs for cross-project consumption
