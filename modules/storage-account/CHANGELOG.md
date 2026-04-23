# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [3.0.0] - 2026-04-18

### Changed

- **BREAKING**: `min_tls_version` accepted value changed from `"TLS1_2"` to `"1.2"` (internal translation maps to provider's `"TLS1_2"` format). Aligns with the canonical `min_tls_version = "1.2"` convention across the module library.
- **BREAKING**: `enable_private_endpoints` renamed to `enable_private_endpoint` (singular). All other PE-creating modules already use singular; storage-account was the outlier.
- **BREAKING**: Private endpoint name overrides consolidated. Removed `private_endpoint_names`, `private_service_connection_names`, and `private_endpoint_nic_names` (maps). Use the new single variable `private_endpoint_name_prefix` (string) to change the PE and NIC stem; per-subresource suffixes are auto-generated. PSC names intentionally stay on `"psc-${var.name}-${subresource}"` regardless of the prefix (PSC names are not user-facing and remain anchored to the storage account name).

### Added

- `private_endpoint_name_prefix` variable. Default `null` → `pep-${var.name}`.

### Fixed

- Moved `subnet_id` validation to a `lifecycle.precondition` on the private endpoint resource (Terraform validation blocks cannot reference other variables)

### Migration

- Consumers passing any of the removed map variables (`private_endpoint_names`, `private_service_connection_names`, `private_endpoint_nic_names`) must drop those arguments. Use `private_endpoint_name_prefix` (string) to change the PE/NIC stem; PSC names remain anchored to `var.name`.
- Consumers passing `min_tls_version = "TLS1_2"` must change the value to `"1.2"` (internal translation preserves the deployed resource).
- Consumers passing `enable_private_endpoints = ...` (plural) must rename to `enable_private_endpoint` (singular).

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
