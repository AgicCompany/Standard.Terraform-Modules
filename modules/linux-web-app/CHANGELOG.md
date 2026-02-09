# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Linux web app creation on existing service plan
- Application stack support (Docker, .NET, Node.js, Python, Java, PHP)
- Private endpoint support for `sites` subresource
- VNet integration for outbound traffic
- System and user-assigned managed identity support
- Application settings and connection strings
- Health check and always-on configuration
- Secure defaults (HTTPS only, TLS 1.2, FTPS disabled, public access disabled)
- Standard outputs: `id`, `name`, `default_hostname`, `outbound_ip_addresses`
- Identity outputs: `principal_id`, `tenant_id`
- Private endpoint outputs: `private_endpoint_id`, `private_ip_address`
- Public outputs for cross-project consumption
