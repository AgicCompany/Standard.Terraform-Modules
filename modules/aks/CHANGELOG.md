# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.4.0] - 2026-02-20

### Added

- Node OS upgrade maintenance window (`maintenance_window_node_os`) with same scheduling options as auto-upgrade window

### Changed

- `maintenance_window` now defaults to Saturday+Sunday 00:00-06:00 UTC instead of null (Azure-managed)
- `maintenance_window_auto_upgrade` now defaults to Weekly Sunday 02:00 UTC, 4h duration instead of null
- `maintenance_window_node_os` defaults to Weekly Saturday 02:00 UTC, 4h duration

### Migration notes

- Consumers who previously relied on `maintenance_window = null` (Azure-managed scheduling) will now get explicit maintenance windows. Pass `maintenance_window = null` to restore the previous behavior.

## [1.3.0] - 2026-02-19

### Added

- Flexible identity support: system-assigned (`enable_system_assigned_identity`), user-assigned (`user_assigned_identity_ids`), or both
- Lifecycle precondition: at least one identity type is required

### Changed

- Identity block is now dynamic (was hardcoded to SystemAssigned)
- Updated `principal_id` and `tenant_id` output descriptions to note SystemAssigned dependency

## [1.2.0] - 2026-02-11

### Added

- Auto-scaler profile tuning (`auto_scaler_profile`) for fine-tuning scale-down thresholds, scan intervals, and cooldown periods
- General maintenance window (`maintenance_window`) for controlling when Azure performs cluster upgrades
- Auto-upgrade maintenance window (`maintenance_window_auto_upgrade`) with frequency, interval, and duration scheduling
- Load balancer profile (`network_profile.load_balancer_profile`) for outbound IP management, idle timeout, and allocated outbound ports
- Private DNS zone customization (`private_dns_zone_id`) for hub-spoke network topologies with centralized DNS

## [1.1.0] - 2026-02-11

### Added

- Workload identity federation (`workload_identity_enabled`) for pod-to-Azure-service authentication
- RBAC authorization mode (`rbac_mode`) supporting Azure RBAC or Kubernetes RBAC
- Key Vault CSI driver add-on (`key_vault_secrets_provider`) for mounting secrets as volumes

## [1.0.0] - 2026-02-09

### Added

- Initial release
- AKS cluster creation with configurable Kubernetes version
- Private cluster (always enabled)
- Default node pool with autoscaling
- Azure CNI Overlay networking (default)
- System-assigned managed identity
- Azure AD integration with Azure RBAC
- Container Insights via Log Analytics
- Configurable upgrade channel
- SKU tier selection (Free, Standard, Premium)
- Authorized IP ranges for API server access
