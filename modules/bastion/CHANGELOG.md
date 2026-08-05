# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.0] - 2026-02-10

### Added

- Initial release
- Azure Bastion host with Basic, Standard, and Developer SKU support
- Automatic public IP provisioning (Standard SKU, static allocation)
- Standard SKU feature gating: file copy, IP connect, shareable links, tunneling, scale units
- Standard outputs: `id`, `name`, `dns_name`, `public_ip_address`, `public_ip_id`
- Public outputs for cross-project consumption
