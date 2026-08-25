# Changelog

All notable changes to this module will be documented in this file.

## [2.1.0] - 2026-08-25

### Added

- `connection_string` sensitive output for declarative telemetry configuration (Azure Monitor OpenTelemetry). Partially reverses the 2.0.0 removal: with `local_authentication_disabled = true` (the default) the connection string identifies the telemetry destination and is not a credential (ingestion requires Entra ID + RBAC). The value resides in Terraform state regardless of the output; marking it `sensitive` keeps it out of plan/apply display. See MODULE_STANDARDS.md §4 (possession test).

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

### Fixed

- README **Security Defaults** section now describes the real defaults: local authentication disabled, internet ingestion disabled, internet query disabled.

## [2.0.0] - 2026-04-24

### Removed
- **BREAKING:** Removed `instrumentation_key`, `connection_string`, and `public_connection_string` outputs. Retrieve via `data.azurerm_application_insights` or Key Vault references instead.

### Fixed
- Updated examples to remove references to deleted `connection_string` output.

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Workspace-based Application Insights
- Configurable application type, retention, daily cap, sampling
- Local authentication toggle
- Connection string and instrumentation key as sensitive outputs
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
