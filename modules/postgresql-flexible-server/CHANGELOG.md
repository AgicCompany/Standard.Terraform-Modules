# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [4.0.1] - 2026-04-18

### Added

- Null-safe password complexity validation on `administrator_password`: min 12 chars; must include upper, lower, digit, and symbol. AAD-only deployments (password == null) are unaffected. Weak passwords now rejected at validate time instead of forwarded to Azure.

### Security

- Password complexity validation aligns with Azure's built-in PostgreSQL Flexible Server complexity rules.

## [4.0.0] - 2026-04-15

### Changed

- **BREAKING:** `enable_entra_auth` now defaults to `true` (was `false`). Pass `enable_entra_auth = false` to preserve previous behavior.

### Fixed

- Added default server configuration enforcing `require_secure_transport = on`

## [3.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name

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
