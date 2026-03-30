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

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Key Vault creation with RBAC authorization (no access policies)
- Soft delete with configurable retention (7-90 days)
- Purge protection (enabled by default)
- Private endpoint with DNS zone group
- Network ACLs support for public access scenarios
- VM integration flags (deployment, disk encryption, template deployment)
- Standard outputs: `id`, `name`, `vault_uri`, `tenant_id`
- Private endpoint outputs: `private_endpoint_id`, `private_ip_address`
- Public outputs for cross-project consumption
