# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- `enable_remote_to_local` variable (default: `true`) allowing one-sided peering creation when the remote VNet is managed separately (`remote_virtual_network_resource_group_name` and `remote_virtual_network_name` now default to `null` and are required only when `enable_remote_to_local = true`).
- `local_use_remote_gateways` and `remote_allow_gateway_transit` variables (default: `false`) for spoke-as-local peering topologies, with preconditions preventing simultaneous gateway transit and remote gateway use on the same peering link.
- Offline `terraform test` suite (`tests/validation.tftest.hcl`, mocked provider).

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Bidirectional VNet peering (local-to-remote and remote-to-local)
- Configurable traffic forwarding and gateway transit
- Standard outputs: `id`, `name`
- Public outputs for cross-project consumption
