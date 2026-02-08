# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - YYYY-MM-DD

### Added

- Initial release
- Network security group creation
- Security rules as separate `azurerm_network_security_rule` resources via `for_each` map
- Support for service tags, CIDR ranges, and application security group references
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
