# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
