# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.2.0] - 2026-06-05

### Added

- `public_ip_name` variable to override PIP resource name (default: `pip-{name}`).
- `nic_name` variable to override NIC resource name (default: `nic-{name}`).
- `managed_disk_name_prefix` variable to override managed disk name prefix (default: `disk-{name}`).

## [1.1.0] - 2026-04-25

### Fixed

- Ternary null-guard fixes in variable validation blocks for Terraform 1.9.x compatibility
- Code review findings: validation, security default, and consistency fixes

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Windows virtual machine with password authentication
- Network interface with optional public IP
- Data disk management with for_each
- System and user-assigned managed identity support
- Boot diagnostics support
- Azure Hybrid Benefit support
- Timezone configuration
- Automatic computer name truncation (15-character limit)
