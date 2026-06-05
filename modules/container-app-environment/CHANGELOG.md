# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [2.0.0] - 2026-06-05

### Changed

- **BREAKING:** `enable_internal_load_balancer` default changed from `true` to `false`. The environment now uses an external load balancer by default, so the minimum-viable configuration no longer requires `infrastructure_subnet_id`. To keep an internal load balancer, set `enable_internal_load_balancer = true` (and provide `infrastructure_subnet_id`).

## [1.0.0] - 2026-02-08

### Added

- Initial release
- Container Apps Environment creation
- Log Analytics workspace integration
- VNet integration with internal load balancer (default)
- Workload profile configuration
- Zone redundancy support
