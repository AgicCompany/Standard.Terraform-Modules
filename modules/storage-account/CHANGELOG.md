# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Fixed

- Moved `subnet_id` validation to a `lifecycle.precondition` on the private endpoint resource (Terraform validation blocks cannot reference other variables)

## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default names changed from `pe-{name}-{sub}` to `pep-{name}-{sub}` (Azure CAF). Pass `private_endpoint_names` map to preserve old behavior.
- **BREAKING**: Private endpoint NICs now use deterministic names `pep-{name}-{sub}-nic` instead of Azure auto-generated names. Pass `private_endpoint_nic_names` map to override.

### Added

- `private_endpoint_names` map variable to override PE resource names per subresource
- `private_service_connection_names` map variable to override PSC names per subresource
- `private_endpoint_nic_names` map variable to override PE NIC names per subresource

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Storage account creation with secure defaults (TLS 1.2, HTTPS only)
- Private endpoints for blob, file, table, queue subresources (configurable per subresource)
- Blob soft delete with configurable retention (1-365 days)
- Container soft delete with configurable retention (1-365 days)
- Blob versioning (optional)
- Network rules support for public access scenarios
- Standard outputs: `id`, `name`, endpoint URLs, location
- Private endpoint outputs: `private_endpoint_ids`, `private_ip_addresses`
- Public outputs for cross-project consumption
