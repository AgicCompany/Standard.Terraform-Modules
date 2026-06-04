# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-05-29

### Added

- Initial release
- Container App Job creation in existing environment
- Three trigger types: event (KEDA scale rules), manual, and schedule (cron)
- Single container template with CPU/memory, env vars, command/args, and health probes
- Init containers
- Secrets: plain value and Azure Key Vault reference
- Private registry authentication via managed identity or username/password
- System and user-assigned managed identity
- `enable_secret_ignore_changes` feature flag (default `true`) to ignore secret changes after
  initial creation — recommended for secrets rotated outside Terraform
