# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Changed

- **BREAKING:** Default `zones` changed from `["1", "2", "3"]` to `null`. Consumers must explicitly set zones appropriate for their region.

## [1.0.0] - 2026-02-11

### Added

- Initial release
- Node pool management via `azurerm_kubernetes_cluster_node_pool` with `for_each` over a `node_pools` map
- Autoscaling support with conditional `node_count`/`min_count`/`max_count`
- Spot instance support with `priority`, `eviction_policy`, and `spot_max_price`
- Windows node pool support via `os_type = "Windows"`
- Per-pool `upgrade_settings` with max surge, drain timeout, and node soak duration
- Node labels and taints for workload scheduling
- Availability zone configuration per pool
- Ultra SSD, host encryption, and FIPS support flags
