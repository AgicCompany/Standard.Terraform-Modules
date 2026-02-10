# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-02-10

### Added

- Initial release
- API Management service creation with configurable SKU
- VNet integration (External and Internal modes)
- Multi-region deployment support (Premium SKU)
- Availability zones support (Premium SKU)
- Private endpoint support for `Gateway` subresource
- System-assigned and user-assigned managed identity support
- Client certificate authentication
- Configurable notification sender email and minimum API version
- Secure defaults (public access disabled, PE enabled, SystemAssigned identity)
- Standard outputs: `id`, `name`, `gateway_url`, `management_api_url`, `developer_portal_url`
- Identity outputs: `principal_id`, `tenant_id`
- Private endpoint outputs: `private_endpoint_id`, `private_ip_address`
- Public outputs for cross-project consumption
