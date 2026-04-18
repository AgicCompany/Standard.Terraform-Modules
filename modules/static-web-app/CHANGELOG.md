# Changelog

All notable changes to this module will be documented in this file.

## [3.0.0] - 2026-04-18

### Changed
- **BREAKING:** `sku_tier` default changed from `"Free"` to `"Standard"`. Pass `sku_tier = "Free"` to preserve previous behavior.
- **BREAKING:** `sku_size` default changed from `"Free"` to `"Standard"`. Pass `sku_size = "Free"` to preserve previous behavior.
- **BREAKING:** `enable_public_access` default changed from `true` to `false`. Standard SKU required; pass `enable_public_access = true` to allow public traffic.
- **BREAKING:** `enable_private_endpoint` default changed from `false` to `true`. Pass `enable_private_endpoint = false` (and `enable_public_access = true`) to opt out of private networking.

### Removed
- **BREAKING:** Removed `api_key` output. Retrieve deployment keys via `az staticwebapp secrets list` or a data source instead.

## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name

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
