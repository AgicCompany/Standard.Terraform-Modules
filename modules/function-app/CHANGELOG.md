# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Linux Function App creation on existing service plan
- Application stack support (.NET, Node.js, Python, Java, PowerShell, Docker)
- Storage account integration (required by Functions runtime)
- Private endpoint support for `sites` subresource
- VNet integration for outbound traffic
- Application Insights integration
- System and user-assigned managed identity support
- Application settings
- Functions runtime version configuration (default `~4`)
- Secure defaults (HTTPS only, TLS 1.2, FTPS disabled, public access disabled)
- Standard outputs: `id`, `name`, `default_hostname`
- Identity outputs: `principal_id`, `tenant_id`
- Private endpoint outputs: `private_endpoint_id`, `private_ip_address`
- Public outputs for cross-project consumption
