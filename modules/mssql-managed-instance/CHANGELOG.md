# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-09-16

### Added

- Initial release: `azurerm_mssql_managed_instance` with secure defaults — Microsoft Entra-only authentication, TLS 1.2 minimum, public data endpoint disabled, system-assigned managed identity.
- Transparent data encryption resource, always present: service-managed key by default, customer-managed Key Vault key via `customer_managed_key` (optional auto-rotation).
- Advanced Threat Protection (`azurerm_mssql_managed_instance_security_alert_policy`) enabled by default, configurable via `security_alert_policy`, opt-out via `enable_security_alert_policy`.
- Optional multi-sink `diagnostic_settings` (Log Analytics, storage account, Event Hub), all supported categories/metrics by default.
- Offline `terraform test` suite (`tests/validation.tftest.hcl`, mocked provider) covering every input validation and precondition.

### Notes

- `sku_name`, `vcores` and `storage_size_in_gb` are **required with no defaults** by design: an instance takes hours to (re)provision, so sizing must be explicit.
- Networking prerequisites (delegated subnet, NSG, route table) are consumer-owned and passed via `subnet_id`.
- Vulnerability assessment is intentionally not wrapped (needs a storage access key input; superseded by Defender for SQL express configuration).
