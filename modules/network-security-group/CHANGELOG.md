# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.3.0] - 2026-06-05

### Fixed

- `protocol` validation now accepts `Esp` and `Ah` (previously rejected at validate time despite being documented as supported in v1.1.0 and accepted by Azure).

## [1.2.0] - 2026-04-25

### Added

- Validation: source/destination address prefix and ASG IDs are now mutually exclusive per rule.
- Validation: rule priorities must be unique within each direction.

## [1.1.0] - 2026-02-19

### Added

- Enum validations on `security_rules[*]`: `direction` (Inbound, Outbound), `access` (Allow, Deny), `protocol` (Tcp, Udp, Icmp, Esp, Ah, *)
- Priority range validation (100–4096)

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Network security group creation
- Security rules as separate `azurerm_network_security_rule` resources via `for_each` map
- Support for service tags, CIDR ranges, and application security group references
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
