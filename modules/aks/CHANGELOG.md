# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
