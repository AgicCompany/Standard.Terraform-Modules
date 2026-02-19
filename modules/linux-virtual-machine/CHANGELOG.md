# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
