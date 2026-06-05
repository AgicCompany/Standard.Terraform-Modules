# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [4.1.1] - 2026-06-05

### Changed

- Reordered variable declarations so the Identity and Diagnostics blocks precede the feature-flags group, per the module interface contract. No interface or behavior change.

## [4.1.0] - 2026-06-05

### Added
- Validation blocks for `default_node_pool.os_disk_type` (Managed, Ephemeral) and `default_node_pool.os_sku` (AzureLinux, Ubuntu, Windows2019, Windows2022).
- Validation blocks for `network_profile.network_plugin` (azure, kubenet, none), `network_profile.network_policy` (azure, calico, cilium), and `network_profile.outbound_type` (loadBalancer, managedNATGateway, userAssignedNATGateway, userDefinedRouting).

## [4.0.0] - 2026-06-05

### Added
- `default_node_pool.name` field (default: "system") allowing consumers to override the default node pool name.

### Changed
- **BREAKING:** `workload_identity_enabled` default changed from `false` to `true`. Consumers who don't want workload identity must pass `workload_identity_enabled = false`.
- **BREAKING:** `enable_auto_scaling` default changed from `true` to `false`. Consumers who want auto-scaling must pass `enable_auto_scaling = true`.
- **BREAKING:** `enable_container_insights` default changed from `true` to `false`. Consumers who want Container Insights must pass `enable_container_insights = true` and provide `log_analytics_workspace_id`.

## [3.0.0] - 2026-04-25

### Removed
- **BREAKING:** Removed `kube_config_raw` output. Use `az aks get-credentials` with Entra auth instead. Raw kubeconfig in Terraform state violates the no-secrets output policy.

## [2.1.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [2.0.0] - 2026-04-18

### Changed

- **BREAKING**: `default_node_pool.zones` default changed from `["1","2","3"]` to `[]`. Rationale: the previous default failed on MPN, sandbox, and many dev-tier subscriptions where not all zones are available. Multi-zone consumers must now set `zones` explicitly.

### Migration

- Consumers who want multi-zone node pools must pass `default_node_pool = { zones = ["1","2","3"] }` (or whichever zones their subscription supports). Consumers on zone-constrained subscriptions now deploy cleanly on the default.

## [1.5.0] - 2026-04-15

### Deprecated

- `kube_config_raw` output is deprecated and will be removed in the next major version. Use `az aks get-credentials` with Azure AD authentication instead.

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
