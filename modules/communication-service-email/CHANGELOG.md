# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Internal: moved the `azurerm_monitor_diagnostic_categories` data source from `main.tf` to `data.tf` for file-structure consistency. No interface or behavior change.
- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.1] - 2026-05-17

### Fixed

- `diagnostic_settings.log_analytics_destination_type` validation uses ternary null guards instead of `||`. Terraform 1.10 does not short-circuit `||` in variable validation conditions, so the previous form passed `null` into `contains()` and aborted `terraform validate`.
- `location` variable annotated with `# tflint-ignore: terraform_unused_declarations`. The variable is deliberately unused by the underlying global ACS resources but is kept on the module for consumer convention.

## [1.0.0] - 2026-05-17

### Added

- Initial release of `communication-service-email` module.
- Composes `azurerm_communication_service`, `azurerm_email_communication_service`, `azurerm_email_communication_service_domain`, `azurerm_email_communication_service_domain_sender_username` (per-entry `for_each`), and `azurerm_communication_service_email_domain_association`.
- Toggleable Azure-managed (`AzureManagedDomain`) vs customer-managed custom domain via `enable_custom_domain`.
- DNS verification records (domain, SPF, DKIM, DKIM2, DMARC) exposed as the `verification_records` output for custom-domain workflows.
- Optional diagnostic settings on the Communication Service (multi-sink, auto-enumerated categories). Email Communication Service does not currently expose diagnostic categories.
- `sender_usernames` output returns each sender's resource ID, local-part username, and computed `from_address` (`<username>@<effective_domain>`).
- No secret outputs. `primary_connection_string` deliberately not exported.

