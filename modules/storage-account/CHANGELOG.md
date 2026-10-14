# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [4.0.0] - 2026-10-13

### Changed

- **BREAKING:** `queue_encryption_key_type` and `table_encryption_key_type` now
  default to `null`, which follows `customer_managed_key` instead of always
  meaning `"Service"`. On a `StorageV2` account with a customer-managed key both
  resolve to `"Account"`, so the key covers queue and table data as well as blob
  and file data. Without a customer-managed key, and on every other account kind,
  both still resolve to `"Service"`. An explicit value always wins.

  Only `StorageV2` gets the flip: `BlockBlobStorage` and `FileStorage` have no
  queue or table data, and `Storage` (GPv1) rejects account-scoped keys for those
  services.

### Migration from 3.4.0

An existing storage account that uses `customer_managed_key` and relied on the
old defaults will plan a **destroy and recreate**, because both attributes are
ForceNew in AzureRM. There is no in-place migration.

To keep such an account exactly as it is, set the old defaults explicitly:

```hcl
queue_encryption_key_type = "Service"
table_encryption_key_type = "Service"
```

To adopt the new behaviour on an existing account, the data has to be moved to a
new account; plan it as a migration, not a version bump.

Accounts without `customer_managed_key` are unaffected and plan no change.

## [3.4.0] - 2026-10-13

### Added

- `queue_encryption_key_type` and `table_encryption_key_type` inputs, both
  defaulting to `"Service"`. Set them to `"Account"` to put queue and table data
  under the account key, which is the customer-managed key when
  `customer_managed_key` is set. Both are ForceNew in AzureRM: changing either
  one after creation destroys and recreates the storage account.
- Plan-time precondition rejecting `"Account"` for either input when
  `account_kind = "Storage"`, which has no account-scoped key for those
  services. The provider raises this at apply time.

### Fixed

- `account_kind = "BlockBlobStorage"` and `account_kind = "Storage"` could never
  plan. Both are accepted by the `account_kind` validation, but the module always
  sent `access_tier`, which AzureRM only allows on `BlobStorage`, `FileStorage`
  and `StorageV2` accounts and rejects at plan time for anything else. The
  attribute is now sent only for the kinds that support it.

### Changed

- README and `examples/cmk` state what `customer_managed_key` actually covers.
  AzureRM puts blob and file data under the account key, but passes queue and
  table data the two inputs above, so before this release queue and table data
  stayed on Microsoft-managed keys with no way to change that from the module.
  The CMK example now sets both to `"Account"`.
- `access_tier` description states which account kinds it applies to. No
  behaviour change for `BlobStorage`, `FileStorage` or `StorageV2` accounts,
  which keep sending the configured value (default `Hot`).
- Manifest help for `access_tier` corrected: it applies to `FileStorage` too,
  and the hide-when note now names `BlockBlobStorage` and `Storage`.

### Notes

- Defaults match the current AzureRM and Azure behaviour, so existing
  configurations plan no change. Accounts already created with
  `customer_managed_key` keep service-scoped queue and table keys; moving them
  to `"Account"` means recreating the account.
- Supersedes the `3.3.1` section this release originally carried. The
  `access_tier` fix and the encryption key type inputs landed in one merge, so
  they ship as a single minor release and `3.3.1` was never tagged.

## [3.3.0] - 2026-10-13

### Added

- Optional `identity` input (`SystemAssigned`, `UserAssigned`, or
  `SystemAssigned, UserAssigned`) rendering the storage account's managed
  identity block.
- Optional `customer_managed_key` input for encryption at rest, taking either a
  Key Vault key (`key_vault_key_id`) or a Managed HSM key
  (`managed_hsm_key_id`) plus the `user_assigned_identity_id` Azure uses to
  reach it. Versionless key IDs are supported and enable automatic key
  rotation. Implemented with the inline `customer_managed_key` block of
  `azurerm_storage_account`; the module creates no key, vault or role
  assignment.
- `identity` output exposing the identity type, principal ID, tenant ID and
  assigned user-assigned identity IDs.
- Plan-time preconditions: `customer_managed_key` requires an `identity` whose
  type includes `UserAssigned` and whose `identity_ids` contain the chosen
  `user_assigned_identity_id`; and it requires `account_kind = "StorageV2"` or
  `account_tier = "Premium"`.
- `examples/cmk` showing a user-assigned identity, a Key Vault Premium RSA-HSM
  3072 key, the required role assignment, and the Managed HSM variant.

### Notes

- Both inputs default to `null`; existing configurations plan no change.
- `managed_hsm_key_id` is mapped onto the provider's `key_vault_key_id`
  attribute, which accepts Key Vault and Managed HSM key IDs alike. The
  provider's own `managed_hsm_key_id` is deprecated and removed in azurerm 5.0,
  so this keeps the module's interface stable across that migration.

## [3.2.1] - 2026-09-16

### Fixed

- `diagnostic_settings` validation crashed `terraform plan` on Terraform 1.10–1.12 (which do not short-circuit `||` in validation conditions) whenever a sink was set without `log_analytics_destination_type`. Rewritten as nested ternaries; no interface or behavior change.

### Added

- Offline `terraform test` regression suite (`tests/validation.tftest.hcl`, mocked provider).

### Changed

- Internal: moved the `azurerm_monitor_diagnostic_categories` data source from `main.tf` to `data.tf` for file-structure consistency. No interface or behavior change.
- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [3.2.0] - 2026-06-05

### Added

- `private_service_connection_name_prefix` variable to override PSC name prefix (default: `psc-{name}`).

## [3.1.1] - 2026-04-25

### Fixed

- `blob_properties` block is now conditional and excluded for `FileStorage` account kind (which only supports file shares).

## [3.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [3.0.0] - 2026-04-18

### Changed

- **BREAKING**: `min_tls_version` accepted value changed from `"TLS1_2"` to `"1.2"` (internal translation maps to provider's `"TLS1_2"` format). Aligns with the canonical `min_tls_version = "1.2"` convention across the module library.
- **BREAKING**: `enable_private_endpoints` renamed to `enable_private_endpoint` (singular). All other PE-creating modules already use singular; storage-account was the outlier.
- **BREAKING**: Private endpoint name overrides consolidated. Removed `private_endpoint_names`, `private_service_connection_names`, and `private_endpoint_nic_names` (maps). Use the new single variable `private_endpoint_name_prefix` (string) to change the PE and NIC stem; per-subresource suffixes are auto-generated. PSC names intentionally stay on `"psc-${var.name}-${subresource}"` regardless of the prefix (PSC names are not user-facing and remain anchored to the storage account name).

### Added

- `private_endpoint_name_prefix` variable. Default `null` → `pep-${var.name}`.

### Fixed

- Moved `subnet_id` validation to a `lifecycle.precondition` on the private endpoint resource (Terraform validation blocks cannot reference other variables)

### Migration

- Consumers passing any of the removed map variables (`private_endpoint_names`, `private_service_connection_names`, `private_endpoint_nic_names`) must drop those arguments. Use `private_endpoint_name_prefix` (string) to change the PE/NIC stem; PSC names remain anchored to `var.name`.
- Consumers passing `min_tls_version = "TLS1_2"` must change the value to `"1.2"` (internal translation preserves the deployed resource).
- Consumers passing `enable_private_endpoints = ...` (plural) must rename to `enable_private_endpoint` (singular).

## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default names changed from `pe-{name}-{sub}` to `pep-{name}-{sub}` (Azure CAF). Pass `private_endpoint_names` map to preserve old behavior.
- **BREAKING**: Private endpoint NICs now use deterministic names `pep-{name}-{sub}-nic` instead of Azure auto-generated names. Pass `private_endpoint_nic_names` map to override.

### Added

- `private_endpoint_names` map variable to override PE resource names per subresource
- `private_service_connection_names` map variable to override PSC names per subresource
- `private_endpoint_nic_names` map variable to override PE NIC names per subresource

## [1.1.0] - 2026-03-03

### Added

- Lifecycle preconditions for private endpoint configuration
- `min_tls_version` validation enforcing `"1.2"` as minimum

### Fixed

- Variable and validation consistency improvements

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Storage account creation with secure defaults (TLS 1.2, HTTPS only)
- Private endpoints for blob, file, table, queue subresources (configurable per subresource)
- Blob soft delete with configurable retention (1-365 days)
- Container soft delete with configurable retention (1-365 days)
- Blob versioning (optional)
- Network rules support for public access scenarios
- Standard outputs: `id`, `name`, endpoint URLs, location
- Private endpoint outputs: `private_endpoint_ids`, `private_ip_addresses`
- Public outputs for cross-project consumption
