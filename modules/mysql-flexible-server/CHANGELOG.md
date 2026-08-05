# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- Internal: moved the `azurerm_monitor_diagnostic_categories` data source from `main.tf` to `data.tf` for file-structure consistency. No interface or behavior change.
- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [4.0.0] - 2026-06-05

### Changed

- **BREAKING:** `enable_public_access` is now wired to the server's `public_network_access` argument (it was previously a documented no-op). With the default `false`, servers created in private-endpoint mode (`enable_private_endpoint = true`, no `delegated_subnet_id`) now have public network access **Disabled by default** — previously it was left enabled by the Azure default. When `delegated_subnet_id` is set, public access stays Disabled as before. To keep public access, set `enable_public_access = true`.

## [3.1.1] - 2026-04-25

### Deprecated
- `enable_public_access` variable: not configurable in AzureRM provider v4+. MySQL Flexible Server auto-computes public access based on network configuration (delegated_subnet_id). Variable retained for interface compatibility but has no effect.

## [3.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [3.0.1] - 2026-04-18

### Added

- Null-safe password complexity validation on `administrator_password`: min 12 chars; must include upper, lower, digit, and symbol. Existing deployments with null passwords or already-compliant passwords are unaffected. Weak passwords now rejected at validate time instead of forwarded to Azure.

### Security

- Password complexity validation aligns with Azure's built-in MySQL Flexible Server complexity rules.

### Added

- Default server configurations enforcing `require_secure_transport = ON` and `tls_version = TLSv1.2` (merged with consumer-supplied `server_configurations`).

## [3.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name

## [2.0.0] - 2026-02-19

### Added

- Private endpoint support (`enable_private_endpoint`, `subnet_id`) as alternative to VNet delegation
- PE outputs: `private_endpoint_id`, `private_ip_address`
- Mutual exclusion precondition: PE and delegation cannot be used simultaneously

### Changed

- **BREAKING:** `enable_private_endpoint` defaults to `true` — existing consumers using delegation must explicitly set `enable_private_endpoint = false`
- `private_dns_zone_id` is now required when either delegation or PE is used (was only required for delegation)
- Renamed VNet Integration section to Private Networking

## [1.0.0] - 2026-02-10

### Added

- Initial release
- MySQL Flexible Server with configurable SKU, version, and storage
- Database management via `for_each` map
- Server configuration parameters via `for_each` map
- Firewall rules via `for_each` map
- VNet integration via delegated subnet
- High availability support (SameZone / ZoneRedundant)
- Custom maintenance window
- Standard outputs: `id`, `name`, `fqdn`
- Public outputs for cross-project consumption
