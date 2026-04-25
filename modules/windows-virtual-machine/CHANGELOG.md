# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- Validation: custom computer_name must be 15 characters or fewer.
- `enable_encryption_at_host` variable (default `true`) -- encrypts temp disks and cached data at rest
- `enable_secure_boot` variable (default `true`) -- enables Secure Boot for Trusted Launch
- `enable_vtpm` variable (default `true`) -- enables vTPM for Trusted Launch

### Changed

- **BREAKING:** New security defaults enable encryption at host, secure boot, and vTPM. Existing consumers not setting these explicitly will get these features enabled.

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
