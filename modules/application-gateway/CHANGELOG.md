# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

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
