# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.3.0] - 2026-06-05

### Added

- `public_ip_name` variable to override PIP resource name (default: `pip-{name}`).
- `nic_name` variable to override NIC resource name (default: `nic-{name}`).
- `managed_disk_name_prefix` variable to override managed disk name prefix (default: `disk-{name}`).

### Changed

- Minimum Terraform version raised to `>= 1.10.0`.

## [1.2.0] - 2026-04-25

### Added

- Precondition: password auth now requires admin_password.

## [1.1.0] - 2026-02-19

### Added

- Optional password authentication (`enable_password_auth`, `admin_password`)
- SSH key is now optional when password auth is enabled
- Lifecycle precondition: at least one auth method (SSH key or password) required

### Changed

- `admin_ssh_public_key` is now optional (default: `null`) — was previously required
- `admin_ssh_key` block is now dynamic, only created when SSH key is provided

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Linux virtual machine with SSH key authentication
- Network interface with optional public IP
- Data disk management with for_each
- System and user-assigned managed identity support
- Boot diagnostics support
- Secure defaults (password auth disabled, no public IP)
