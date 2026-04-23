# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.2.0] - 2026-04-18

### Added

- Optional `diagnostic_settings` variable enabling multi-sink `azurerm_monitor_diagnostic_setting` creation (Log Analytics Workspace, Storage Account, Event Hub). Defaults to `null` (disabled) for backward compatibility. When set, all resource-supported log categories and metrics are enabled by default; `enabled_log_categories` and `enabled_metrics` let consumers narrow the selection.

## [1.1.0] - 2026-02-19

### Added

- Enum validations on `http_settings[*].protocol` (Http, Https), `cookie_based_affinity` (Enabled, Disabled), `routing_rules[*].rule_type` (Basic, PathBasedRouting), `redirect_configurations[*].redirect_type` (Permanent, Found, SeeOther, Temporary)
- Lifecycle preconditions for SSL certificate and authentication certificate constraints

### Fixed

- Added `ssl_policy` block using Azure predefined policy `AppGwSslPolicy20220101` enforcing TLS 1.2 minimum

## [1.0.0] - 2026-02-10

### Added

- Initial release
- Application Gateway v2 with autoscaling (Standard_v2 and WAF_v2)
- Public IP (Standard SKU, Static allocation)
- Backend address pools (FQDN and IP targets)
- Backend HTTP settings with affinity, timeouts, and host headers
- HTTP/HTTPS listeners with host-based routing
- Request routing rules (Basic and PathBasedRouting)
- Health probes with custom match conditions
- SSL certificates (PFX upload or Key Vault reference)
- Redirect configurations
- URL path maps for path-based routing
- Availability zone support
- HTTP/2 enabled by default
- External WAF policy attachment
- Standard outputs: `id`, `name`, `public_ip_address`, `public_ip_id`, `backend_address_pool_ids`
- Public outputs for cross-project consumption
