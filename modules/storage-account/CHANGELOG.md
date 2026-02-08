# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
