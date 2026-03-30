# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Cosmos DB account with SQL API
- SQL database management via `for_each` map with autoscale support
- Configurable consistency policy
- Multi-region geo-replication with automatic failover
- Private endpoint with DNS zone integration
- Periodic and continuous backup policies
- IP firewall and authentication controls
- Standard outputs: `id`, `name`, `endpoint`
- Public outputs for cross-project consumption
