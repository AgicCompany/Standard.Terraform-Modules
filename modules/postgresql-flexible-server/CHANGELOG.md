# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
