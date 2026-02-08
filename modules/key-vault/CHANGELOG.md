# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
