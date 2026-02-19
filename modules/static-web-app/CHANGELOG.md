# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-02-19

### Added

- Private endpoint support (`enable_private_endpoint`, `subnet_id`, `private_dns_zone_id`)
- Public network access control (`enable_public_access`, default: disabled)
- PE outputs: `private_endpoint_id`, `private_ip_address`
- SKU precondition: PE requires Standard SKU
- Complete example updated with VNet, PE subnet, and private DNS zone

## [1.0.0] - 2026-02-10

### Added

- Initial release
- Static Web App creation with Free/Standard SKU
- Application settings (environment variables)
- Preview environments for pull requests
- Configuration file changes control
- Standard outputs: `id`, `name`, `default_host_name`, `api_key`
- Public outputs for cross-project consumption
