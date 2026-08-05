# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Internal: moved the `azurerm_monitor_diagnostic_categories` data source from `main.tf` to `data.tf` for file-structure consistency. No interface or behavior change.
- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.1] - 2026-05-17

### Fixed

- `managed_network_isolation_mode` and `diagnostic_settings.log_analytics_destination_type` validations use ternary null guards instead of `||`. Terraform 1.10 does not short-circuit `||` in variable validation conditions, so the previous form passed `null` into `contains()` and aborted `terraform validate`.
- `examples/basic` and `examples/complete` use `rbac_authorization_enabled` on `azurerm_key_vault` instead of the deprecated `enable_rbac_authorization` (will be removed in AzureRM 5.x).

## [1.0.0] - 2026-05-17

### Added

- Initial release of `ai-foundry` module.
- Wraps `azurerm_ai_foundry` (hub) + `azurerm_ai_foundry_project` (one default project).
- BYO dependencies: `storage_account_id`, `key_vault_id` required; `application_insights_id`, `container_registry_id` optional.
- Managed identity: defaults to `SystemAssigned`; supports `UserAssigned` and `SystemAssigned, UserAssigned`.
- Optional managed network isolation, customer-managed encryption, and high business impact mode.
- Optional private endpoint targeting the `amlworkspace` subresource.
- Optional diagnostic settings using the standard module object pattern (multi-sink, auto-enumerated categories).
- Outputs: `id`, `name`, `workspace_id`, `discovery_url`, `principal_id`, `tenant_id`, `project_id`, `project_name`, `project_workspace_id`, `private_endpoint_id`, `private_endpoint_ip_address`.
- No secret outputs.

